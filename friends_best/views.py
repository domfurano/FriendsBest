from rest_framework import viewsets
from rest_framework import status
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

    def list(self, request, *args, **kwargs):
        query_dict = dict()
        tag_list = QueryTag.objects.all().values('query', 'tag',)
        for tag in tag_list:
            qid = tag['query']
            tag_value = tag['tag']
            timestamp = Query.objects.filter(id=qid).get().timestamp
            if qid in query_dict:
                query_dict[qid]['tags'].append(tag_value)
            else:
                query_dict[qid] = {'id': qid, 'tags':[tag_value], 'timestamp':timestamp}
        print(query_dict)
        query_list = list(query_dict.values())
        return Response(query_list)

    def create(self, request, *args, **kwargs):
        serializer = QuerySerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            data = serializer.data
            queryid = data.pop('queryId', None)
            return Response({queryid: data}, status.HTTP_201_CREATED)
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

