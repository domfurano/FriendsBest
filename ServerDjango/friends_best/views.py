from rest_framework import viewsets, mixins
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

class QueryViewSet(viewsets.ModelViewSet):
    queryset = Query.objects.all()
    serializer_class = QuerySerializer
    permission_classes = (permissions.IsAuthenticated, Owner)

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
            return Response(serializer.data, status.HTTP_201_CREATED)
        return Response(data, status.HTTP_400_BAD_REQUEST)

class ThingViewSet(viewsets.ModelViewSet):
    queryset = Thing.objects.order_by('thingType')
    serializer_class = ThingSerializer

class RecommendationViewSet(viewsets.ModelViewSet):
    queryset = Recommendation.objects.order_by('user')
    serializer_class = RecommendationSerializer
    permission_classes = (permissions.IsAuthenticated, OwnerOrReadOnly)

    def create(self, request, *args, **kwargs):
        data = request.data
        data["user"] = request.user.id
        serializer = RecommendationSerializer(data=data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status.HTTP_201_CREATED)
        return Response(serializer.errors, status.HTTP_400_BAD_REQUEST)

class TextThingViewSet(viewsets.ModelViewSet):
    queryset = TextThing.objects.order_by('thing')
    serializer_class = TextSerializer

# Limited to GET HEAD DELETE OPTIONS
# http://stackoverflow.com/questions/23639113/disable-a-method-in-a-viewset-django-rest-framework
class PromptViewSet(mixins.RetrieveModelMixin,
                    mixins.DestroyModelMixin,
                    viewsets.GenericViewSet):
    
    queryset = Prompt.objects.order_by('user')
    serializer_class = PromptSerializer
    permission_classes = (permissions.IsAuthenticated, OwnerCanReadDelete)
    
    def list(self, request):
         prompts = getPrompts(request.user)
         serializer = PromptSerializer(prompts, many=True)
         return Response(serializer.data)
         
    # When deleting a prompt now, we rely on default behavior.
    # In the future we might want to hide prompts so that
    # friends can't get spammed by a repeat query.
    # def destroy(self, request):
    
class FriendViewSet(mixins.RetrieveModelMixin,
                    mixins.UpdateModelMixin,
                    viewsets.GenericViewSet):
    permission_classes = (permissions.IsAuthenticated, OwnerCanReadDelete)
    serializer_class = FriendshipSerializer
    queryset = Friendship.objects
    
    def list(self, request):
        friends = Friendship.objects.filter(userOne=request.user).all()
        serializer = FriendshipSerializer(friends, many=True)
        return Response(serializer.data)
    
    # GET friendship
    def retrieve(self, request, pk=None):
        friendship = getFriendship(request.user, pk)
        if friendship:
            # Serialize and return friendship
            serializer = FriendshipSerializer(friendship.first(), many=False)
            return Response(serializer.data)
        return Response({'detail': 'not found'}, status.HTTP_404_NOT_FOUND)
        
    # PUT to change muted
    def update(self, request, pk=None, **kwargs):
        friendship = getFriendship(request.user, pk)
        if friendship:
            partial = kwargs.pop('partial', False)
            
            # in the event we got an empty put, unmute
            if "muted" not in request.data.keys():
                request.data["muted"] = False
                
            serializer = self.get_serializer(friendship.first(), data=request.data, partial=partial)
            serializer.is_valid(raise_exception=True)
            self.perform_update(serializer)
            return Response(serializer.data)
        return Response({'detail': 'not found'}, status.HTTP_404_NOT_FOUND)
    
#     def update(request, *args, **kwargs):
#         
#         
#     def partial_update(request, *args, **kwargs):
#         
                    

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
    
    def login(self):
        getCurrentFriendsListFromFacebook(self.serializer.validated_data['user'])
        return SocialLoginView.login(self)
        

