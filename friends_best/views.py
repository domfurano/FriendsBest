from rest_framework import viewsets
from friends_best.serializers import *


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.order_by('name')
    serializer_class = UserSerializer


class FriendViewSet(viewsets.ModelViewSet):
    queryset = Friend.objects.order_by('user')
    serializer_class = FriendsSerializer


class QueryViewSet(viewsets.ModelViewSet):
    queryset = Query.objects.order_by('user_id')
    serializer_class = QuerySerializer


class ThingViewSet(viewsets.ModelViewSet):
    queryset = Thing.objects.order_by('type')
    serializer_class = ThingSerializer


class RecommendationViewSet(viewsets.ModelViewSet):
    queryset = Recommend.objects.order_by('thing_id')
    serializer_class = RecommendSerializer


class TextViewSet(viewsets.ModelViewSet):
    queryset = Text.objects.order_by('thing_id')
    serializer_class = TextSerializer

