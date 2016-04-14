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
from .models import Notification
from .models import RejectedTag


import friends_best.serializers

# from .models import RecommendationTag
# from .models import QueryTag
from .models import Tag
from django.utils import timezone
from datetime import datetime, timedelta

from allauth.socialaccount.models import SocialAccount
from allauth.socialaccount.models import SocialToken

import sys

import requests
import json


from nltk.stem import WordNetLemmatizer
from django.db.models import Q
from random import randint

_naughtyWords = ([
    'poop',
    'booger',
    'boogers',
    'whore',
    'shit',
    'fuck',
    'ass',
    'asshole',
    'queer',
    'strip',
    'damn',
    'fart',
    'douche',
    'butt',
    'dick',
    'boobs',
    'boob',
    'cock',
    'tits',
    'penis',
    'crap',
    'boner',
    '',
    '',
    '',
])




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


# <editor-fold desc="Accolades">
def getAccolades(user):
    return Accolade.objects.filter(user=user).all()


def deleteAccolade(accoladeId):
    Accolade.objects.get(id=accoladeId).delete()
# </editor-fold>


# <editor-fold desc="Prompts">
def getPrompts(user):
    # Get prompts, ordered by query timestamp
    prompts = Prompt.objects.filter(user=user).order_by('query__timestamp')
    # if user has no prompts, generate some anonymous prompts and return them
    if prompts.count() == 0:
        generateAnonymousPrompts(user)
        return Prompt.objects.filter(user=user).order_by('query__timestamp')
    else:
        return prompts


# currently not being used by serializer
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





def generateAnonymousPrompts(user):
    # get all queries made by users who are not friends with the user
    queriesByStrangers = Query.objects.prefetch_related('tags').exclude(Q(user__friendship1__userTwo=user) | Q(user=user)).all()
    queryCount = queriesByStrangers.count()

    if queryCount == 0:
        return

    # create list of most frequent tags associated with prompts that have been rejected by the user (get random 15 of top 20)
    rejectedTags = RejectedTag.objects.select_related('tag__lemma').filter(user=user)
    rtCount = rejectedTags.count()
    badLemmas = []
    if rtCount >= 20:  # only get the list if user has at least 20 rejected tags
        weightedRejectedTags = []
        for rt in rejectedTags:
            weightedRejectedTags.append((rt.tag, rt.tagSum))
        # reverse sort tags by frequency and get top 20 items
        weightedRejectedTags = sorted(weightedRejectedTags, key=lambda wrt: wrt[1], reverse=True)[:20]

        length = len(weightedRejectedTags)
        randomIndexes = generateRandomIndexes(15, length)
        for randomIndex in randomIndexes:
            badLemmas.append(weightedRejectedTags[randomIndex].lemma)

    # exclude any queries with tag lemmas included in the bad lemma list
    queriesByStrangers = queriesByStrangers.exclude(tags__lemma__in=badLemmas)

    # select random queries and generate prompts for them
    randomIndexes = generateRandomIndexes(5, queryCount)

    userRecommendations = Recommendation.objects.filter(user=user)
    for randomIndex in randomIndexes:
        query = queriesByStrangers[randomIndex]
        queryTags = Tag.objects.filter(query=query)

        # don't create prompt if query has any dirty words
        hasNaughtyWords = False
        for tag in queryTags:
            if tag.tag in _naughtyWords:
                hasNaughtyWords = True
                break

        if hasNaughtyWords:
            continue

        queryLemmas = [tag.lemma for tag in queryTags]

        # only create prompt if user has no recommendation such that its tags include every tag in the randomly selected query
        allLemmasMatch = False
        for rec in userRecommendations:
            recTags = Tag.objects.filter(recommendation=rec)
            recLemmas = [tag.lemma for tag in recTags]
            allLemmasMatch = True
            for lemma in queryLemmas:
                if not lemma in recLemmas:
                    allLemmasMatch = False
                    break
            if allLemmasMatch:
                break

        if not allLemmasMatch:
            p, created = Prompt.objects.get_or_create(user=user, query=query, isAnonymous=True)


# private helper method (creates a set of random indexes for the specified collection)
# loopRange = number of indexes returned (fewer indexes are returned if any indexes are randomly selected more than once)
# length = length of collection
def generateRandomIndexes(loopRange, length):
    if loopRange < 0 or length < 1:
        return "error: invalid parameter(s) for generating random indexes"

    randomIndexes = set()
    for x in range(0, loopRange):
        randomIndex = randint(0, length - 1)
        randomIndexes.add(randomIndex)

    return randomIndexes


#client will call for this whenever a prompt is swiped left (or when a recommendation is created after swiping right)
def deletePrompt(promptId):
    prompt = Prompt.objects.select_related('query__tags', 'user').get(id=promptId)
    tags = prompt.query.tags
    user = prompt.user

    # check for a recently created recommendation related to the prompt
    promptTags = [tag.tag for tag in tags]
    recentRecs = Recommendation.objects.filter(user=user, timestamp__gte=(timezone.now()-timedelta(seconds=10)))
    allTagsMatch = False
    for rec in recentRecs:
        if allTagsMatch:
            break
        recTags = Tag.objects.filter(recommendation=rec)
        for recTag in recTags:
            if recTag.tag not in promptTags:
                allTagsMatch = False
                break
            else:
                allTagsMatch = True

    # track tags related to the deleted prompt
    if not allTagsMatch:
        for tag in tags:
            rt, created = RejectedTag.objects.get_or_create(user=user, tag=tag)
            #if tag/user pair already exists in db, increment the counter
            if not created:
                rt.tagSum += 1
                rt.save()

    prompt.delete()


def forwardPrompt(user, friendUserId, queryId):
   p, created = Prompt.objects.get_or_create(user=User.objects.get(id=friendUserId), query=Query.objects.get(id=queryId))
   # TODO: how do we tell the client who forwarded the prompt???


# this will ensure that new users get normal prompts immediately
def generatePromptsForNewUser(user):
    allFriends = getAllFriendUsers(user)
    recentFriendQueries = Query.objects.filter(user__in=allFriends, timestamp__gte=(timezone.now()-timedelta(days=3)))
    print(recentFriendQueries.count())
    for query in recentFriendQueries:
        p, created = Prompt.objects.get_or_create(user=user, query=query, isAnonymous=False)

# </editor-fold>


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


# <editor-fold desc="Queries">
def submitQuery(user, *tags):
    if tags.count == 0:
        return "error: cannot submit query, query must include at least one tag"

    #TODO: delete after testing
    #sendNotification({'user':'test user 666', 'text': 'test text 666'}, "recommendations")

   # create hash of tags and ordered string
    taghash = ' '.join(sorted(set(tags)))
    tagstring = ' '.join(tags)

    # create a query
    q1, created = Query.objects.get_or_create(user=user, taghash=taghash)

    q1.tagstring = tagstring
    q1.timestamp = timezone.now()

    # create query tags
    lemmas = set()
    tagsWithoutDuplicates = set(tags)
    for t in tagsWithoutDuplicates:
        lemma = _lemmatizer.lemmatize(word=t.lower(), pos='n')
        lemmas.add(lemma)
        qt, created = Tag.objects.get_or_create(tag=t.lower(), lemma=lemma)
        q1.tags.add(qt)

    q1.save()


    # check for inappropriate words in query


    for tag in tagsWithoutDuplicates:
        if tag in _naughtyWords:
            return q1

    # create self prompt as a test
    # remove this when we can test that friends work
    #p, created = Prompt.objects.get_or_create(user=user, query=q1)


    # create prompts for all of user's friends (but only if the friend doesn't already have a relevant recommendation)
    allFriends = getAllFriendUsers(user)
    for friendUser in allFriends:

        #single tag match logic
        #friendTags = Tag.objects.filter(recommendation__user=friendUser).all()
        #lemmaMatch = False
        #for friendTag in friendTags:
        #if friendTag.lemma in lemmas:
        #        lemmaMatch = True
        #        break
        #if not lemmaMatch:
        #    p, created = Prompt.objects.get_or_create(user=friendUser, query=q1, isAnonymous=False)

        # create prompt if friend user has no recommendation such that its tags include every tag in the query
        friendRecommendations = Recommendation.objects.prefetch_related('tags').filter(user=friendUser)
        allLemmasMatch = False
        for rec in friendRecommendations:
            recTags = Tag.objects.filter(recommendation=rec)
            recLemmas = [tag.lemma for tag in recTags]
            allLemmasMatch = True
            for lemma in lemmas:
                if not lemma in recLemmas:
                    allLemmasMatch = False
                    break
            if allLemmasMatch:
                break
        if not allLemmasMatch:
            p, created = Prompt.objects.get_or_create(user=friendUser, query=q1, isAnonymous=False)

            #just for testing
            #identifiedUmair = isUmair(friendUser)
            #print ("found umair while creating prompts?: " + "yes" if identifiedUmair else "no")
            if created and isUmair(friendUser):
                sendNotification(serializers.PromptSerializer(p).data, "prompts")

    # create prompts for subscribed users who are not friends of the user
    #subscribedUsers = User.objects.filter(subscription__tag__lemma__in=lemmas).exclude(Q(friendship__userOne=user) | Q(friendship__userTwo=user))
    #subscribedUsers = User.objects.filter(subscription__tag__lemma__in=lemmas)
    #for su in subscribedUsers:
    #    p, created = Prompt.objects.get_or_create(user=su, query=q1, isAnonymous=True)

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

    #TODO: take into account the number of recommendation tags that don't match
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
       thingId = thing.id
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
       notifications = Notification.objects.select_related('recommendation').filter(query=query)
       newRecs = [n.recommendation for n in notifications] # recommendations not yet seen by querying user
       recommendationsWithFlags = []
       newRecommendationCount = 0
       recommendedByFriend = False  # thing is recommended by at least one friend
       for recommendation in recommendations:
           isNew = recommendation in newRecs
           recommendationsWithFlags.append(RecommendationWithFlag(recommendation=recommendation, isNew=isNew))
           if isNew: newRecommendationCount += 1
           if not recommendedByFriend or isFriendsWith(query.user, recommendation.user):
               recommendedByFriend = True

       pins = Pin.objects.filter(thing=thing, query=query)
       pinId = pins[0].id if pins.count() > 0 else False
       # if any of the recommendations for the solution are from a friend of the querying user, prepend the solution to the solution list, otherwise append
       if recommendedByFriend:
           solutionsWithTags['solutions'].insert(recommendationsFromFriendsCount, Solution(detail=detail, recommendationsWithFlags=recommendationsWithFlags, solutionType=thing.thingType, pinId=pinId, totalNewRecommendations=newRecommendationCount, id=thingId))
           recommendationsFromFriendsCount += 1
       else:
           solutionsWithTags['solutions'].append(Solution(detail=detail, recommendationsWithFlags=recommendationsWithFlags, solutionType=thing.thingType, pinId=pinId, totalNewRecommendations=0, id=thingId))

   return solutionsWithTags


def getQueryHistory(user):
   # Order-by done to return the queries in the right order (from oldest run to newest)
   return Query.objects.filter(user=user).order_by('timestamp').prefetch_related('tags').all()
   # TODO: wouldn't we want to just return the query object and then derive from it the tagstring?
   # ANSWER: From what I read, prefetching related reduces the number of selects made to the database.
   # See https://docs.djangoproject.com/en/dev/ref/models/querysets/


def getQuery(user, queryId):
   return Query.objects.filter(user=user, id=queryId).prefetch_related('tags')
# </editor-fold>


# <editor-fold desc="Facebook Integration">
def getUserFacebookToken(user):
   account = SocialAccount.objects.filter(user=user).first()
   token = SocialToken.objects.filter(account=account).first()
   return token.token


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
# </editor-fold>


# <editor-fold desc="Notifications">
def deleteNotification(recId):
    Notification.get(recommendation=Recommendation.objects.get(id=recId)).delete()
# </editor-fold>


# <editor-fold desc="Recommendations">
def getRecommendations(user):
   return Recommendation.objects.filter(user=user).order_by('timestamp').prefetch_related('tags').all()


def modifyRecommendation(recId, newComments, *newTagStrings):
    rec = Recommendation.objects.prefetch_related('tags').get(id=recId)
    rec.comments = newComments

    # if line 530 throws an exception, use this instead:
    recTags = Tag.objects.filter(recommendation=rec)

    oldTagStrings = set()
    for recTag in recTags:
        oldTagString = recTag.tag
        oldTagStrings.add(oldTagString)
        if oldTagString not in newTagStrings:
            rec.tags.remove(recTag)

    for newTagString in newTagStrings:
        if newTagString not in oldTagStrings:
            newTag, created = Tag.objects.get_or_create(tag=newTagString.lower(), lemma=_lemmatizer.lemmatize(word=newTagString.lower(), pos='n'))
            rec.tags.add(newTag)

    rec.save()
    
    return rec;


def deleteRecommendation(recId):
   Recommendation.objects.get(id=recId).delete()


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
   lemmas = set()
   for t in tags:
       lemma = _lemmatizer.lemmatize(word=t.lower(), pos='n')
       lemmas.add(lemma)
       newtag, created = Tag.objects.get_or_create(tag=t.lower(), lemma=lemma)
       recommendation.tags.add(newtag)

   # create a notification for every existing query with a matching tag
   queries = Query.objects.select_related('user').filter(tags__lemma__in=lemmas)
   for query in queries:
      n = Notification(query=query, recommendation=recommendation)
      n.save()

      #just for testing
      #identifiedUmair = isUmair(query.user)
      #print ("found umair while creating recommendation?: " + "yes" if identifiedUmair else "no")
      if isUmair(query.user):
          sendNotification(serializers.RecommendationSerializer(recommendation).data, "recommendations")

   return recommendation
# </editor-fold>


# <editor-fold desc="Friendships/muting">
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
# </editor-fold>


# <editor-fold desc="Things/auto-complete">
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
# </editor-fold>


# <editor-fold desc="Pins">
def createPin(thingId, queryId):
    
    # create pin
    thing = Thing.objects.filter(id=thingId)[0]
    query = Query.objects.filter(id=queryId)[0]
    pin, created = Pin.objects.get_or_create(thing=thing, query=query)

    # create accolades
    recs = Recommendation.objects.select_related('user').filter(thing=thing).all()
    for rec in recs:
        a, created = Accolade.objects.get_or_create(user=rec.user, recommendation=rec)
    
    # return new or exisiting pin
    return pin


def deletePinById(pinId):
   Pin.objects.filter(id=pinId).delete()


def deletePin(thingId, queryId):
   thing = Thing.objects.filter(id=thingId)[0]
   query = Query.objects.filter(id=queryId)[0]
   Pin.objects.filter(thing=thing, query=query)[0].delete()
# </editor-fold>



# TODO
def deleteAccount(userId):
   pass


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


# for class demo tag cloud
#def getRecommendationTagCounts():
#    tags = RecommendationTag.objects.values_list("tag", flat=True)
#    tagSet = set(tags)  # put in a set to eliminate duplicates
#    tag_count_list = []
#    for tag in tagSet:
#        count = Tag.objects.filter(tag=tag).count()
#        tag_count_list.append({'text': tag, 'weight': count})
#    return tag_count_list


class Solution:
   def __init__(self, detail, recommendationsWithFlags, solutionType, pinId, totalNewRecommendations, id):
       self.detail = detail
       self.recommendationsWithFlags = recommendationsWithFlags
       self.solutionType = solutionType.lower()
       self.pinId = pinId
       self.totalNewRecommendations = totalNewRecommendations
       self.id = id  # this is the thing id


class RecommendationWithFlag:
    def __init__(self, recommendation, isNew):
        self.recommendation = recommendation
        self.isNew = isNew



def isUmair(user):
    account = SocialAccount.objects.filter(user=user).first()
    if account.uid == 139982843051386:
        print ("i found umair!")
        return True
    else:
        print ("i did not find umair")
        return False


from gcm import *
from threading import Timer
from queue import Queue

# http://django-gcm.readthedocs.org/en/latest/quickstart.html

API_KEY = "AIzaSyBaz-fjyd6BOXNosuKf-bvgsakpI2nGyjs"
TIME_TO_WAIT = 30.0
_gcm = GCM(API_KEY)
_q = Queue()

def sendNotification(json_data, topic):

   if not topic == "recommendations" and not topic == "prompts":
       return "error: notification topic must be 'recommendations' or 'prompts'"

   # Hard coded value, replace with actual server data
   #data = {'user':'test user', 'tagString': 'test text'}
   data = json_data

   _q.put(data)
   # can be either recommendations or prompts
   #topic = 'recommendations'

   response = _gcm.send_topic_message(topic=topic, data=data)
   print ("notification response: %s" % response)

   global TIME_TO_WAIT
   if not response or 'success' not in response:
       # Try again later
       data = _q.remove()
       t = Timer(TIME_TO_WAIT, sendNotification(data))
       TIME_TO_WAIT *= 2
       t.start()
   else:
       _q.pop()
       TIME_TO_WAIT = 30.0
       print("Sent to GCM")




