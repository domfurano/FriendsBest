from rest_framework import viewsets
from rest_framework import status
from rest_framework.parsers import JSONParser
from rest_framework.response import Response

from friends_best.serializers import *


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.order_by('userName')
    serializer_class = UserSerializer


class FriendViewSet(viewsets.ModelViewSet):
    queryset = Friendship.objects.order_by('userOne')
    serializer_class = FriendsSerializer


class QueryViewSet(viewsets.ModelViewSet):
    queryset = Query.objects.order_by('id')
    serializer_class = QuerySerializer

    def create(self, request):
        query_id = QuerySerializer(request)

        if query_id:
            return Response({"queryId": query_id}, status.HTTP_201_CREATED)
        return Response(status.HTTP_400_BAD_REQUEST)


class ThingViewSet(viewsets.ModelViewSet):
    queryset = Thing.objects.order_by('thingType')
    serializer_class = ThingSerializer


class RecommendationViewSet(viewsets.ModelViewSet):
    queryset = Recommendation.objects.order_by('user')
    serializer_class = RecommendationSerializer

    def create(self, request, *args, **kwargs):
        serializer = RecommendationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"recommendationId": serializer.data}, status.HTTP_201_CREATED)
        return Response(serializer.errors, status.HTTP_400_BAD_REQUEST)


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

