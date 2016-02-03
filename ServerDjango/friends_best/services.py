from logging import warning, error
## from .models import User
from django.contrib.auth.models import User
from .models import Friendship
from .models import Query
from .models import Thing
from .models import TextThing
from .models import Recommendation
# from .models import RecommendationTag
# from .models import QueryTag
from .models import Tag
from django.utils import timezone

from allauth.socialaccount.models import SocialAccount
from allauth.socialaccount.models import SocialToken

import sys

def submitQuery(userId, *tags):
    if tags.count == 0:
        return "query must include at least one tag"

    # create hash of tags and ordered string
    taghash = ' '.join(sorted(set(tags)))
    tagstring = ' '.join(tags)

    # create a query
    u1 = User.objects.get(id=userId)
    q1, created = Query.objects.get_or_create(user=u1, taghash=taghash)
    
    q1.tagstring=tagstring
    q1.timestamp=timezone.now()

    # create query tags
    for t in tags:
         qt, created = Tag.objects.get_or_create(tag=t.lower())
         q1.tags.add(qt)
    
    q1.save()
    
    return q1


def userTest(user):
	
	account = SocialAccount.objects.filter(user=user).first()
	token = SocialToken.objects.filter(account=account).first()
	
	print(account.uid)
	print(token.token)


def getQuerySolutions(query):

    tags = query.tags.all()
    
    recommendations = Recommendation.objects.filter(tags__in=tags).all()

    things = []
    for recommendation in recommendations:
        things.append(recommendation.thing)
    things = set(things)  # put in a set to eliminate duplicates

    # compile solutions (each solution is a thing as well as the userName and comments of each associated recommendation)
    solutionsWithQueryTags = {'tags': [tag.tag for tag in tags], 'solutions': [], 'count': len(recommendations)}
    for thing in things:
        description = TextThing.objects.filter(thing_id=thing.id)[0].description
        recommendations = Recommendation.objects.filter(thing=thing)
        userComments = []
        for recommendation in recommendations:
            firstName = recommendation.user.first_name
            lastName = recommendation.user.last_name
            comments = recommendation.comments
            dictionary = {}
            dictionary['name'] = firstName + " " + lastName
            dictionary['comment'] = comments
            userComments.append(dictionary)
        solutionsWithQueryTags['solutions'].append(Solution(description=description, userComments=userComments))

    return solutionsWithQueryTags


def getQueryHistory(userId):
    return Query.objects.filter(user=User.objects.get(id=userId)).prefetch_related('tags').all()
    
def getQuery(userId, queryId):
    return Query.objects.filter(user=User.objects.get(id=userId), id=queryId).prefetch_related('tags')

def createUser(userName):
    user = User(userName=userName)
    user.save()

    return user.id


def createFriendship(userOneId, userTwoId):
    u1 = User.objects.get(id=userOneId)
    u2 = User.objects.get(id=userTwoId)
    f1 = Friendship(userOne=u1, userTwo=u2)
    f2 = Friendship(userOne=u2, userTwo=u1)
    f1.save()
    f2.save()


def createRecommendation(userId, description, comments, *tags):
    if len(tags) == 0:
        return "recommendation must include at least one tag"

    # if a thing with same content doesn't already exist, create a new thing (and corresponding textthing)
    # otherwise get the existing thing
    if TextThing.objects.filter(description=description).count() == 0:
        thing = Thing()
        thing.save()
        text = TextThing(thing=thing, description=description)
        text.save()
    else:
        thing = TextThing.objects.filter(description=description)[0].thing

    recommendation = Recommendation(thing=thing, user=User.objects.get(id=userId), comments=comments)
    recommendation.save()

    # create the recommendationTags
    for t in tags:
        newtag, created = Tag.objects.get_or_create(tag=t.lower())
        recommendation.tags.add(newtag)
         
    return recommendation.id


# for class demo tag cloud
def getRecommendationTagCounts():
    tags = RecommendationTag.objects.values_list("tag", flat=True)
    tagSet = set(tags)  # put in a set to eliminate duplicates
    tag_count_list = []
    for tag in tagSet:
        count = Tag.objects.filter(tag=tag).count()
        tag_count_list.append({'text': tag, 'weight': count})
    return tag_count_list
    
    
def createTextThing(description):
    thing = Thing()
    thing.save()
    text = TextThing(thing=thing, description=description)
    text.save()


def createPin():
    pass


def createPrompt():
    pass


class Solution:
    def __init__(self, description, userComments):
        self.description = description
        self.userComments = userComments


