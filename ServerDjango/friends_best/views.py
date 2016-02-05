from rest_framework import viewsets
from rest_framework.views import APIView
from rest_framework import status
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.request import Request
from allauth.socialaccount.providers.facebook.views import FacebookOAuth2Adapter
from rest_auth.registration.views import SocialLoginView
from allauth.socialaccount.models import SocialAccount
from django.utils import timezone

from friends_best.serializers import *
from friends_best.services import *
from friends_best.permissions import *

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.order_by('userName')
    serializer_class = UserSerializer
    
class CurrentUserView(APIView):
	def get(self, request):
		user = request.user
		accounts = SocialAccount.objects.get(user=user)
		serializer = UserSerializer(user)
		return Response(serializer.data)
    
class CurrentSocialUserView(APIView):
	def get(self, request):
		user = request.user
		accounts = SocialAccount.objects.get(user=user)
		serializer = UserSocialSerializer(accounts)
		return Response(serializer.data)

class FriendViewSet(viewsets.ModelViewSet):
    queryset = Friendship.objects.order_by('userOne')
    serializer_class = FriendsSerializer

class QueryViewSet(viewsets.ModelViewSet):
    queryset = Query.objects.all()
    serializer_class = QuerySerializer
    permission_classes = (permissions.IsAuthenticated, IsOwner)

    def list(self, request):
         history = getQueryHistory(request.user.id)
         serializer = QuerySerializer(history, many=True)
         return Response(serializer.data)
         
    def retrieve(self, request, pk=None):
        instance = self.get_object()
        
        # update the query to have the current time
        # so that it appears in the proper sequence
        # of all queries made by the user
        instance.timestamp = timezone.now()
        instance.save()
        
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    def create(self, request, *args, **kwargs):
        data = request.data
        data["user"] = request.user.id
        serializer = QuerySerializer(data=data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            data = serializer.data
            return Response(data, status.HTTP_201_CREATED)
        return Response(data, status.HTTP_400_BAD_REQUEST)

class ThingViewSet(viewsets.ModelViewSet):
    queryset = Thing.objects.order_by('thingType')
    serializer_class = ThingSerializer

class RecommendationViewSet(viewsets.ModelViewSet):
    queryset = Recommendation.objects.order_by('user')
    serializer_class = RecommendationSerializer
    permission_classes = (permissions.IsAuthenticated, IsOwnerOrReadOnly)

    def create(self, request, *args, **kwargs):
        data = request.data
        data["user"] = request.user.id
        serializer = RecommendationSerializer(data=data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response({"recommendationId": serializer.data}, status.HTTP_201_CREATED)
        return Response(serializer.errors, status.HTTP_400_BAD_REQUEST)

class TextThingViewSet(viewsets.ModelViewSet):
    queryset = TextThing.objects.order_by('thing')
    serializer_class = TextSerializer

class PromptViewSet(viewsets.ModelViewSet):
    queryset = Prompt.objects.order_by('user')
    serializer_class = PromptSerializer


class RecommendationTagViewSet(viewsets.ModelViewSet):
    queryset = Tag.objects.order_by('recommendation')
    serializer_class = TagSerializer

    def list(self, request, *args, **kwargs):
        data = getRecommendationTagCounts()
        return Response(data)


class QueryTagViewSet(viewsets.ModelViewSet):
    queryset = Tag.objects.order_by('query')
    serializer_class = TagSerializer


class PinViewSet(viewsets.ModelViewSet):
    queryset = Pin.objects.order_by('thing')
    serializer_class = PinSerializer
    
class FacebookLogin(SocialLoginView):
    adapter_class = FacebookOAuth2Adapter    

