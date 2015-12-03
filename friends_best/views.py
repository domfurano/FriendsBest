from rest_framework import viewsets
from rest_framework.decorators import detail_route
from rest_framework import status
from rest_framework.response import Response

from friends_best.serializers import *


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class FriendViewSet(viewsets.ModelViewSet):
    queryset = Friendship.objects.order_by('userOne')
    serializer_class = FriendsSerializer


class QueryViewSet(viewsets.ModelViewSet):
    queryset = Query.objects.order_by('id')
    serializer_class = QuerySerializer

    #
    # def create(self, request):
    #     if True:
    #         return Response(request, status.HTTP_400_BAD_REQUEST)
    #     query_id = QuerySerializer(request.body)
    #
    #     if query_id is not None:
    #         return Response({"queryId": query_id}, status.HTTP_201_CREATED)
    #     return Response(status.HTTP_400_BAD_REQUEST)


class ThingViewSet(viewsets.ModelViewSet):
    queryset = Thing.objects.order_by('thingType')
    serializer_class = ThingSerializer


class RecommendationViewSet(viewsets.ModelViewSet):
    queryset = Recommendation.objects.order_by('user')
    serializer_class = RecommendationSerializer


class TextThingViewSet(viewsets.ModelViewSet):
    queryset = TextThing.objects.order_by('thing')
    serializer_class = TextSerializer


class PromptViewSet(viewsets.ModelViewSet):
    queryset = Prompt.objects.order_by('user')
    serializer_class = PromptSerializer


class RecommendationTagViewSet(viewsets.ModelViewSet):
    queryset = RecommendationTag.objects.order_by('recommendation')
    serializer_class = RecommendationTagSerializer


class QueryTagViewSet(viewsets.ModelViewSet):
    queryset = QueryTag.objects.order_by('query')
    serializer_class = QueryTagSerializer


class PinViewSet(viewsets.ModelViewSet):
    queryset = Pin.objects.order_by('thing')
    serializer_class = PinSerializer

