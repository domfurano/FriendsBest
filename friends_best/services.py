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

    # TODO: generate prompts

    # find all relevant recommendations (with any matching tags)
    # TODO: configure solutions according to friendships
    things = []
    for t in tags:
        things.append(RecommendationTag.objects.filter(tag=t).recommendation.thing)

    things = set(things)

    # compile solutions (each solution is a thing as well as the user and comments of each associated recommendation)
    solutions = []
    for thing in things:
        content = TextThing.objects.filter(thing_id=thing.id)[0].content
        recommendations = Recommendation.objects.filter(thing=thing)
        users = []
        comments = []
        for recommendation in recommendations:
            users.append(recommendation.user)
            comments.append(recommendation.comments)
        solutions.append(Solution(content, users, comments))

    return solutions


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


def createRecommendation(userId, content, comments, *tags):

    if tags.count == 0:
        return "recommendation must include at least one tag"

    # if a thing with same content doesn't already exist, create a new thing (and corresponding textthing)
    # otherwise get the existing thing
    if TextThing.objects.filter(content=content).count() == 0:
        thing = Thing()
        thing.save()
        text = TextThing(thing=thing, content=content)
        text.save()
    else:
        thing = TextThing.objects.filter(content=content)[0].thing

    recommendation = Recommendation(thing=thing, user=User.objects.get(userId), comments=comments)
    recommendation.save()


def createPin():
    pass


def createPrompt():
    pass


class Solution:
    def __init__(self, content, *users, *comments):
        self.content = content
        self.users = users
        self.comments = comments


