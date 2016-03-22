from logging import warning, error
## from .models import User
from django.contrib.auth.models import User
from .models import Friendship
from .models import Query
from .models import Thing
from .models import TextThing
from .models import PlaceThing
from .models import UrlThing
from .models import Recommendation
from .models import Prompt
from .models import Pin
from .models import Subscription
from .models import Accolade

# from .models import RecommendationTag
# from .models import QueryTag
from .models import Tag
from django.utils import timezone

from allauth.socialaccount.models import SocialAccount
from allauth.socialaccount.models import SocialToken

import sys

import requests
import json


from nltk.stem import WordNetLemmatizer
from django.db.models import Q



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

_lemmatizer = WordNetLemmatizer() # 'pos' arg = part of speech (defaults to 'noun'); 'n' = noun, 'a' = adjective, 'v' = verb, etc.



# for reference:
# https://docs.djangoproject.com/en/1.9/ref/models/querysets/
# https://docs.djangoproject.com/en/1.9/topics/db/queries/


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


# currently not being used
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


# TODO
def getAccolades(user):
    pass


# TODO
def generateAnonymousPrompts(user):
   # get all queries made by users who are not friends with the user
   queries = Query.objects.exclude(Q(user__friendship__userOne=user) | Q(user__friendship__userTwo=user)).all()

   # select random query and generate a prompt



#client will call for this whenever a prompt is swiped left (or when a recommendation is created after swiping right)
def deletePrompt(promptId):
   Prompt.objects.filter(id=promptId).delete()


def forwardPrompt(user, friendUserId, queryId):
   p, created = Prompt.objects.get_or_create(user=User.objects.get(id=friendUserId), query=Query.objects.get(id=queryId))
   # TODO: how do we tell the client who forwarded the prompt???


# <editor-fold desc="Subscriptions">
def addSubscription(user, tagString):
   lemma = _lemmatizer.lemmatize(word=tagString.lower(), pos='n')
   t1, created = Tag.get_or_create(tag=tagString, lemma=lemma)
   s1, created = Subscription.get_or_create(user=user, tag=t1)


def removeSubscription(user, tag):
    Subscription.objects.get(user=user, tag=tag).delete()


def getAllSubscriptions(user):
    return Subscription.objects.filter(user=user)
# </editor-fold>



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
   lemmas = set()
   for t in tags:
       lemma = _lemmatizer.lemmatize(word=t.lower(), pos='n')
       lemmas.add(lemma)
       qt, created = Tag.objects.get_or_create(tag=t.lower(), lemma=lemma)
       q1.tags.add(qt)

   q1.save()

   # create self prompt as a test
   # remove this when we can test that friends work
   #p, created = Prompt.objects.get_or_create(user=user, query=q1)


   # create prompts for all of user's friends (but only if the friend doesn't already have a relevant recommendation)
   # (assumes that the user's query will receive all recommendations with at least one matching lemma)
   allFriends = getAllFriendUsers(user)
   for friendUser in allFriends:
       # friendTags = Tag.objects.select_related('lemma').filter(recommendation__user=friendUser).all()  # this was an improper use of select_related (might cause an error)
        friendTags = Tag.objects.filter(recommendation__user=friendUser).all()

        lemmaMatch = False
        for friendTag in friendTags:
            if friendTag.lemma in lemmas:
                lemmaMatch = True
                break
        if not lemmaMatch:
            p, created = Prompt.objects.get_or_create(user=friendUser, query=q1)


   # create prompts for subscribed users who are not friends of the user
   subscribedUsers = User.objects.filter(subscription__tag__lemma__in=lemmas).exclude(Q(friendship__userOne=user) | Q(friendship__userTwo=user))
   for su in subscribedUsers:
       p, created = Prompt.objects.get_or_create(user=su, query=q1)

   return q1


def getQuerySolutions(query):

   tags = query.tags.all()
   lemmas = [tag.lemma for tag in tags]

   #recommendations = Recommendation.objects.filter(tags__in=tags).all()
   # match query tag lemmas with recommendation tag lemmas
   recommendations = Recommendation.objects.filter(tags__lemma__in=lemmas).all()

   things = []
   for recommendation in recommendations:
       things.append(recommendation.thing)
   things = set(things)  # put in a set to eliminate duplicates


   weightedThings = []  # list of tuples (thing, average recommendation lemma match for that thing)
   for thing in things:
       # get average number of matching lemmas for each recommendation
       recs = Recommendation.objects.filter(thing=thing).all()
       matchingLemmaCount = 0
       for rec in recs:
           for tag in Tag.objects.filter(recommendation=rec):
               if tag.lemma in lemmas:
                   matchingLemmaCount += 1
       averageLemmaMatch = matchingLemmaCount / recs.count()
       weightedThings.append((thing, averageLemmaMatch))

   # sort list of things according to relevance to search tags (i.e., average number of matching lemmas for each recommendation)
   weightedThings = sorted(weightedThings, key=lambda wt: wt[1], reverse=True)


   # compile solutions (each solution is a thing as well as the userName and comments of each associated recommendation)
   solutionsWithTags = {'tags': [tag.tag for tag in tags], 'solutions': [], 'count': len(recommendations)}
   recommendationsFromFriendsCount = 0
   for wt in weightedThings:
       thing = wt[0]
       detail = ""  # for a text thing this is the description; for a place thing this is the placeId
       if thing.thingType.lower() == 'text':
           detail = TextThing.objects.filter(thing_id=thing.id)[0].description
       elif thing.thingType.lower() == 'place':
           detail = PlaceThing.objects.filter(thing_id=thing.id)[0].placeId
       elif thing.thingType.lower() == 'url':
           detail = UrlThing.objects.filter(thing_id=thing.id)[0].url
       else:
           return "error: thing type'" + thing.thingType + "' is invalid"
       recommendations = Recommendation.objects.filter(thing=thing)
       recommendedByFriend = False  # thing is recommended by at least one friend
       for recommendation in recommendations:
           if isFriendsWith(query.user, recommendation.user):
               recommendedByFriend = True
               break

       isPinned = Pin.objects.filter(thing=thing, query=query).count() >= 1
       # if any of the recommendations for the solution are from a friend of the querying user, prepend the solution to the solution list, otherwise append
       if recommendedByFriend:
           solutionsWithTags['solutions'].insert(recommendationsFromFriendsCount, Solution(detail=detail, recommendations=recommendations, solutionType=thing.thingType, isPinned=isPinned))
           recommendationsFromFriendsCount += 1
       else:
           # TODO: sort non-friend recommendations by degrees of separation
           solutionsWithTags['solutions'].append(Solution(detail=detail, recommendations=recommendations, solutionType=thing.thingType, isPinned=isPinned))

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


def modifyRecommendation(recId, comments, tags):
   rec = Recommendation.objects.filter(id=recId)[0]
   rec.comments = comments

   rec.tags.delete()
   for t in tags:
       newtag, created = Tag.objects.get_or_create(tag=t.lower(), lemma=_lemmatizer.lemmatize(word=t.lower(), pos='n'))
       rec.tags.add(newtag)


def deleteRecommendation(recId):
   Recommendation.objects.filter(id=recId)[0].delete()


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
   friend = User.objects.filter(id=user2ID)[0]
   if friend:
       # Check to see if friendship exisits
       friendship = Friendship.objects.filter(userOne=user1, userTwo=friend)
       if friendship:
           return friendship
   return False


def muteFriendship(friend1Id, friend2Id):
   user1 = User.objects.filter(id=friend1Id)[0]
   user2 = User.objects.filter(id=friend2Id)[0]
   friendship = Friendship.objects.filter(userOne=user1, userTwo=user2)
   friendship.muted = True


def unmuteFriendship(friend1Id, friend2Id):
   user1 = User.objects.filter(id=friend1Id)[0]
   user2 = User.objects.filter(id=friend2Id)[0]
   friendship = Friendship.objects.filter(userOne=user1, userTwo=user2)
   friendship.muted = False


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
   elif thingType.lower() == 'url':
       if UrlThing.objects.filter(url=detail).count() == 0:
           thing = Thing(thingType='Url')
           thing.save()
           url = UrlThing(thing=thing, url=detail)
           url.save()
       else:
           thing = UrlThing.objects.filter(url=detail)[0].thing
   else:
       return "error: thing type '" + thingType + "' is invalid."


   recommendation = Recommendation(thing=thing, user=user, comments=comments)
   recommendation.save()

   # create the recommendationTags
   for t in tags:
       newtag, created = Tag.objects.get_or_create(tag=t.lower(), lemma=_lemmatizer.lemmatize(word=t.lower(), pos='n'))
       recommendation.tags.add(newtag)

   return recommendation


#def createPlaceRecommendation():
#    pass


# for class demo tag cloud
#def getRecommendationTagCounts():
#    tags = RecommendationTag.objects.values_list("tag", flat=True)
#    tagSet = set(tags)  # put in a set to eliminate duplicates
#    tag_count_list = []
#    for tag in tagSet:
#        count = Tag.objects.filter(tag=tag).count()
#        tag_count_list.append({'text': tag, 'weight': count})
#    return tag_count_list


def getTextThingAutocompleteSuggestions(string):
    textThings = TextThing.objects.filter(description__istartswith=string).order_by('description')
    return [tt.description for tt in textThings]


def getUrlThingAutocompleteSuggestions(url):
    urlThings = UrlThing.objects.filter(url__contains=url).order_by('url')
    return [ut.url for ut in urlThings]


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


def createUrlThing(url):
   thing = Thing(thingType="Url")
   thing.save()
   u1 = UrlThing(thing=thing, url=url)
   u1.save()


def createPin(thingId, queryId):
   thing = Thing.objects.filter(id=thingId)[0]
   query = Query.objects.filter(id=queryId)[0]
   pin = Pin(thing=thing, query=query)
   pin.save()

   #create accolades
   recs = Recommendation.objects.select_related('user').filter(thing=thing).all()
   for rec in recs:
       a1 = Accolade(user=rec.user, recommendation=rec)
       a1.save()


def deletePinById(pinId):
   Pin.objects.filter(id=pinId).delete()


def deletePin(thingId, queryId):
   thing = Thing.objects.filter(id=thingId)[0]
   query = Query.objects.filter(id=queryId)[0]
   Pin.objects.filter(thing=thing, query=query)[0].delete()

#def createPrompt():
#    pass


# TODO
def deleteAccount(userId):
   pass



class Solution:
   def __init__(self, detail, recommendations, solutionType, isPinned):
       self.detail = detail
       self.recommendations = recommendations
       self.solutionType = solutionType
       self.isPinned = isPinned



