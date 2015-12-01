from .models import User
from .models import Friendship
from .models import Query
from .models import Thing
from .models import TextThing
from .models import Recommendation
from .models import Prompt
from .models import RecommendationTag
from .models import QueryTag
from .models import Pin


def submitQuery(userId, *tags):

    if tags.count == 0:
        return "query must include at least one tag"

    # create a query
    u1 = User.objects.get(id=userId)
    q1 = Query(user=u1)
    q1.save()

    # create query tags
    for t in tags:
        qt = QueryTag(query=q1, tag=t)
        qt.save()

    return q1.id


def getQuerySolutions(queryId):
    # find all relevant recommendations (with any matching tags)
    # TODO: configure solutions according to friendships
    q1 = Query.objects.get(id=queryId)
    tags = QueryTag.objects.filter(query=q1)
    things = []
    for t in tags:
        things.append(RecommendationTag.objects.filter(tag=t).recommendation.thing)

    things = set(things)  # put in a set to eliminate duplicates

    # compile solutions (each solution is a thing as well as the userName and comments of each associated recommendation)
    solutions = []
    for thing in things:
        description = TextThing.objects.filter(thing_id=thing.id)[0].description
        recommendations = Recommendation.objects.filter(thing=thing)
        dictionary = {}
        for recommendation in recommendations:
            userName = recommendation.user.userName
            comments = recommendation.comments
            dictionary[userName] = comments
        solutions.append(Solution(description, dictionary))

    return solutions


def getQueryHistory(userId):
    return Query.objects.filter(user=User.objects.get(id=userId))


def createUser(userName):
    user = User(userName)
    user.save()


def createFriendship(userOneId, userTwoId):
    u1 = User.objects.get(id=userOneId)
    u2 = User.objects.get(id=userTwoId)
    f1 = Friendship(userOne=u1, userTwo=u2)
    f2 = Friendship(userOne=u2, userTwo=u1)
    f1.save()
    f2.save()


def createRecommendation(userId, description, comments, *tags):

    if tags.count == 0:
        return "recommendation must include at least one tag"

    # if a thing with same content doesn't already exist, create a new thing (and corresponding textthing)
    # otherwise get the existing thing
    if TextThing.objects.filter(description=description).count() == 0:
        thing = Thing()
        thing.save()
        text = TextThing(thing=thing, description=cdescription)
        text.save()
    else:
        thing = TextThing.objects.filter(description=description)[0].thing

    recommendation = Recommendation(thing=thing, user=User.objects.get(userId), comments=comments)
    recommendation.save()

    # create the recommendationTags
    for tag in tags:
        rTag = RecommendationTag(recommendation=recommendation, tag=tag)
        rTag.save()

    return recommendation.id


# for class demo tag cloud
def getRecommendationTagCounts():
    tags = RecommendationTag.objects.values('tag')
    tagSet = set(tags)  # put in a set to eliminate duplicates
    dictionary = {}
    for tag in tagSet:
        dictionary[tag] = RecommendationTag.objects.filter(tag=tag).count()
    return dictionary


def createPin():
    pass


def createPrompt():
    pass


class Solution:
    def __init__(self, description, **userComments):
        self.description = description
        self.userComments = userComments


