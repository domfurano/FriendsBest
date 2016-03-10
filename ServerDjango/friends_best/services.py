from logging import warning, error
## from .models import User
from django.contrib.auth.models import User
from .models import Friendship
from .models import Query
from .models import Thing
from .models import TextThing
from .models import PlaceThing
from .models import Recommendation
from .models import Prompt
# from .models import RecommendationTag
# from .models import QueryTag
from .models import Tag
from django.utils import timezone

from allauth.socialaccount.models import SocialAccount
from allauth.socialaccount.models import SocialToken

import sys

import requests
import json

_baseFacebookURL = 'https://graph.facebook.com/v2.5'

# paul's app:
# _appId = "106243083075609"
# _appSecret = "fb3095e2871ce3f42f43163b0a903c23"
# my user id: 10208457124655040
# long term token : CAABgoKU6ABkBACYatShqKKOIizPUp1E33IwIypcUDjuVyaOAWrA4ZAHZAWPWfqQ7eNIqTTkAA7vx6DM73MC5Q2ajmFSZBHuWQs0P1oMZBvYtZAyMuKibaOZA1jZBChtzPekFu0cuEBlsP413hGZCZBGtRHQ2jiOZBx2BWhiL0ZC0pBNUNaxaOO4g7dm

# TODO: enable these variables (and disable Paul's) before checkin
# ray's app:
_appId = "1519942364964737"
_appSecret = "9346ae3c5b2c50801237589b238b0688"

_genericAccessToken = _appId + "|" + _appSecret


def userTest(user):
    account = SocialAccount.objects.filter(user=user).first()
    token = SocialToken.objects.filter(account=account).first()


def getUserFacebookToken(user):
    account = SocialAccount.objects.filter(user=user).first()
    token = SocialToken.objects.filter(account=account).first()
    return token.token

def getPrompts(user):
    # Get prompts, ordered by query timestamp
    return Prompt.objects.filter(user=user).order_by('query__timestamp')

def getAllPrompts(user):
    prompts = Prompt.objects.filter(user=user)
    promptList = []
    for prompt in prompts:
        d = {}
        d['name'] = '' + prompt.query.user.first_name + prompt.query.user.last_name
        d['tagstring'] = prompt.query.tagstring
        d['id'] = prompt.id
        promptList.append(d)
    return promptList


#client will call for this whenever a prompt is swiped left (or when a recommendation is created after swiping right)
def deletePrompt(promptId):
    Prompt.objects.filter(id=promptId).delete()


def submitQuery(user, *tags):
    if tags.count == 0:
        return "error: cannot submit query, query must include at least one tag"

    # create hash of tags and ordered string
    taghash = ' '.join(sorted(set(tags)))
    tagstring = ' '.join(tags)

    # create a query
    q1, created = Query.objects.get_or_create(user=user, taghash=taghash)
    
    q1.tagstring = tagstring
    q1.timestamp = timezone.now()

    # create query tags
    for t in tags:
         qt, created = Tag.objects.get_or_create(tag=t.lower())
         q1.tags.add(qt)
    
    q1.save()

    # create self prompt as a test
    # remove this when we can test that friends work
    #p, created = Prompt.objects.get_or_create(user=user, query=q1)
    
    # create prompts for all of user's friends
    allFriends = getAllFriendUsers(user)
    for friendUser in allFriends:
        p, created = Prompt.objects.get_or_create(user=friendUser, query=q1)
    
    return q1


def getQuerySolutions(query):

    tags = query.tags.all()
    
    recommendations = Recommendation.objects.filter(tags__in=tags).all()

    things = []
    for recommendation in recommendations:
        things.append(recommendation.thing)
    things = set(things)  # put in a set to eliminate duplicates

    # compile solutions (each solution is a thing as well as the userName and comments of each associated recommendation)
    solutionsWithTags = {'tags': [tag.tag for tag in tags], 'solutions': [], 'count': len(recommendations)}
    for thing in things:
        detail = ""  # for a text thing this is the description; for a place thing this is the placeId
        if thing.thingType.lower() == 'text':
            detail = TextThing.objects.filter(thing_id=thing.id)[0].description
        elif thing.thingType.lower() == 'place':
            detail = PlaceThing.objects.filter(thing_id=thing.id)[0].placeId
        recommendations = Recommendation.objects.filter(thing=thing)
        recommendedByFriend = False  # thing is recommended by at least one friend
        for recommendation in recommendations:
            if isFriendsWith(query.user, recommendation.user):
                recommendedByFriend = True
                break

        # if any of the recommendations for the solution are from a friend of the querying user, prepend the solution to the solution list, otherwise append
        if recommendedByFriend:
            solutionsWithTags['solutions'].insert(0, Solution(detail=detail, recommendations=recommendations, solutionType=thing.thingType))
        else:
            solutionsWithTags['solutions'].append(Solution(detail=detail, recommendations=recommendations, solutionType=thing.thingType))

    return solutionsWithTags


# private
def isFriendsWith(user1, user2):
   if Friendship.objects.filter(userOne=user1, userTwo=user2).count() >= 1:
       return True
   else:
       return False


# private
def getAllFriendUsers(user):
    allFriends = []
    for friendship in Friendship.objects.filter(userOne=user, muted=False):
        allFriends.append(friendship.userTwo)
    return allFriends


# private (returns a set, not a list)
def getAllFriendsFacebookUserIds(user):
    allFriends = set()
    #for friendship in Friendship.objects.filter(userOne=user, muted=False):
    # when using the previous where muted=False, login fails because we try to re-add users that are just muted...
    for friendship in Friendship.objects.filter(userOne=user):
        allFriends.add(SocialAccount.objects.filter(user=friendship.userTwo).first().uid)
    return allFriends


def getCurrentFriendsListFromFacebook(user):
    
    facebookUserId = SocialAccount.objects.filter(user=user).first().uid

    # this will only include friends who have a friendsbest account
    payload = {'access_token': getUserFacebookToken(user)}
    url = _baseFacebookURL + "/" + facebookUserId + "/friends?access_token=" + getUserFacebookToken(user)
    r = requests.get(url)
    if r.status_code != 200:
        print("failed to get user's friends")
        return "error: failed to get user's friends"    
    jsonDict = json.loads(r.text)  # convert json response to dictionary
    allFriends = []
    allFriendsFacebookIds = getAllFriendsFacebookUserIds(user)  # this is retrieved from the db (not Facebook.com)
    for friend in jsonDict['data']:

        # update Friendship table  (friend['id'] is the facebookuserid)
        friendId = friend['id']
        # if friend is not already in the db, save it in the db
        if not friendId in allFriendsFacebookIds:
            friend = SocialAccount.objects.filter(uid=friendId)
            if friend:
                createFriendship(user, friend.first().user)
                
        allFriendsFacebookIds.discard(friendId)  # remove friendId from the set

    # remove all remaining friends (i.e., friends left in the set) from the db
    for friendId in allFriendsFacebookIds:
        #deleteFriendship(user, User.objects.filter(facebookUserId=friendId).first())
        friend = SocialAccount.objects.filter(uid=friendId)
        if friend:
            deleteFriendship(user, friend.first().user)

    #return allFriends


def exchangeShortTermTokenForLongTermToken(user, shortTermToken):
    payload = {'grant_type': 'fb_exchange_token', 'client_id': _appId, 'client_secret': _appSecret, 'fb_exchange_token': shortTermToken}
    r = requests.post(_baseFacebookURL + "/oauth/access_token/", data=payload)
    jsonDict = json.loads(r.text)  # convert json response to dictionary

    longTermToken = jsonDict['access_token']

    account = SocialAccount.objects.filter(user=user).first()
    token = SocialToken.objects.filter(account=account).first()
    token.token = longTermToken

    return longTermToken


def getFacebookUserIdFromFacebook(user):
    payload = {'input_token': getUserFacebookToken(user), 'access_token': _genericAccessToken}
    r = requests.get("https://graph.facebook.com/v2.5/debug_token", params=payload)
    jsonDict = json.loads(r.text)['data']  # convert json response to dictionary
    isValidShortCode = jsonDict['is_valid'].lower()
    if r.status_code != "200" or isValidShortCode == 'false':
        return "error: invalid token"

    #userFacebookId = jsonDict.get('data', {}).get('user_id')
    userFacebookId = jsonDict['user_id']

    return userFacebookId


def getQueryHistory(user):
    # Order-by done to return the queries in the right order (from oldest run to newest)
    return Query.objects.filter(user=user).order_by('timestamp').prefetch_related('tags').all()
    # TODO: wouldn't we want to just return the query object and then derive from it the tagstring?
    # ANSWER: From what I read, prefetching related reduces the number of selects made to the database.
    # See https://docs.djangoproject.com/en/dev/ref/models/querysets/

def getRecommendations(user):
    return Recommendation.objects.filter(user=user).order_by('timestamp').prefetch_related('tags').all()

def getQuery(user, queryId):
    return Query.objects.filter(user=user, id=queryId).prefetch_related('tags')

#def createUser(userName):
#    user = User(userName=userName)
#    user.save()

#    return user.id


def createFriendship(user1, user2):
    f1 = Friendship(userOne=user1, userTwo=user2)
    f2 = Friendship(userOne=user2, userTwo=user1)
    f1.save()
    f2.save()
    
# Returns friendship or false if friendship doesn not exist.
def getFriendship(user1, user2ID):
    # Check to see if user2 exists
    friend = User.objects.filter(id=user2ID)
    if friend:
        # Check to see if friendship exisits
        friendship = Friendship.objects.filter(userOne=user1, userTwo=friend)
        if friendship:
            return friendship
    return False

def deleteFriendship(user1, user2):
    f1 = Friendship.objects.filter(userOne=user1, userTwo=user2).first()
    f2 = Friendship.objects.filter(userOne=user2, userTwo=user1).first()
    f1.delete()
    f2.delete()


# if thing is a PlaceThing, put in the placeId as the description
def createRecommendation(user, detail, thingType, comments, *tags):
    if len(tags) == 0:
        return "error: recommendation must include at least one tag"

    # if a thing with same content doesn't already exist, create a new thing (and corresponding textthing)
    # otherwise get the existing thing
    if thingType.lower() == 'text':
        if TextThing.objects.filter(description=detail).count() == 0:
            thing = Thing(thingType='Text')
            thing.save()
            text = TextThing(thing=thing, description=detail)
            text.save()
        else:
            thing = TextThing.objects.filter(description=detail)[0].thing
    elif thingType.lower() == 'place':
        if PlaceThing.objects.filter(placeId=detail).count() == 0:
            thing = Thing(thingType='Place')
            thing.save()
            place = PlaceThing(thing=thing, placeId=detail)
            place.save()
        else:
            thing = PlaceThing.objects.filter(placeId=detail)[0].thing


    recommendation = Recommendation(thing=thing, user=user, comments=comments)
    recommendation.save()

    # create the recommendationTags
    for t in tags:
        newtag, created = Tag.objects.get_or_create(tag=t.lower())
        recommendation.tags.add(newtag)
         
    return recommendation

# for class demo tag cloud
#def getRecommendationTagCounts():
#    tags = RecommendationTag.objects.values_list("tag", flat=True)
#    tagSet = set(tags)  # put in a set to eliminate duplicates
#    tag_count_list = []
#    for tag in tagSet:
#        count = Tag.objects.filter(tag=tag).count()
#        tag_count_list.append({'text': tag, 'weight': count})
#    return tag_count_list
    
    
def createTextThing(description):
    thing = Thing(thingType='Text')
    thing.save()
    text = TextThing(thing=thing, description=description)
    text.save()


def createPlaceThing(placeId):
    thing = Thing(thingType='Place')
    thing.save()
    place = PlaceThing(thing=thing, placeId=placeId)
    place.save()


def createPin():
    pass


#def createPrompt():
#    pass


class Solution:
    def __init__(self, detail, recommendations, solutionType):
        self.detail = detail
        self.recommendations = recommendations
        self.solutionType = solutionType


