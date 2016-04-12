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
from django.http import HttpResponse
from django.shortcuts import render
import hmac
import os
import json
import subprocess

from friends_best.serializers import *
from friends_best.services import *
from friends_best.permissions import *

def queryLink(request, query_id):
    # Get the query
    try:
        q = Query.objects.get(id=query_id)
        context = {
            'id': query_id,
            'tagstring': q.tagstring
        }
    except Query.DoesNotExist:
        context = {}
    
    return render(request, 'friends_best/link.html', context)

class CurrentUserViewSet(viewsets.GenericViewSet):
    queryset = User.objects.order_by('userName')
    serializer_class = UserSerializer
    
    def list(self, request):
        user = request.user
        accounts = SocialAccount.objects.get(user=user)
        serializer = UserSerializer(user)
        me = serializer.data
        me["friends"] = Friendship.objects.filter(userOne=user).count()
        me["recommendations"] = Recommendation.objects.filter(user=user).count()
        return Response(me)
    
class CurrentSocialUserView(APIView):
	def get(self, request):
		user = request.user
		accounts = SocialAccount.objects.get(user=user)
		serializer = UserSocialSerializer(accounts)
		return Response(serializer.data)

class QueryViewSet(mixins.RetrieveModelMixin,
					mixins.DestroyModelMixin,
                   viewsets.GenericViewSet):
    queryset = Query.objects.all()
    serializer_class = QuerySerializer
    permission_classes = (permissions.IsAuthenticated, Owner)

    # POST
    def create(self, request, *args, **kwargs):
        data = request.data
        data["user"] = request.user.id
        serializer = QuerySerializer(data=data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status.HTTP_201_CREATED)
        return Response(data, status.HTTP_400_BAD_REQUEST)

    # GET
    def list(self, request):
         history = getQueryHistory(request.user.id)
         serializer = QuerySerializer(history, many=True)
         return Response(serializer.data)
    
    # GET id   
    def retrieve(self, request, pk=None):
        instance = self.get_object()
        
        # update the query to have the current time
        # so that it appears in the proper sequence
        # of all queries made by the user
        instance.timestamp = timezone.now()
        instance.save()
        
        serializer = self.get_serializer(instance)
        return Response(serializer.data)
    
    # PUT id to change tags
    # DOES NOTHING!
    def update(self, request, pk=None, **kwargs):
        query = self.get_object()
        serializer = self.get_serializer(query)
        return Response(serializer.data)

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
        
    # GET
    def list(self, request):
        recommendations = getRecommendations(request.user.id)
        serializer = RecommendationSerializer(recommendations, many=True)
        return Response(serializer.data)

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
    
    # GET
    def list(self, request):
         prompts = getPrompts(request.user)
         serializer = PromptSerializer(prompts, many=True)
         return Response(serializer.data)
         
    # When deleting a prompt now, we rely on default behavior.
    # In the future we might want to hide prompts so that
    # friends can't get spammed by a repeat query...
    # def destroy(self, request):

class NotificationViewSet(  mixins.DestroyModelMixin,
                            viewsets.GenericViewSet):
    
    queryset = Notification.objects.order_by('query')
    
    def destroy(self, request, pk=None):
        # pk is the id of the recommendation
        try:
            r = Recommendation.objects.get(pk=pk);
            n = Notification.objects.filter(query__user=request.user, recommendation=r);
            n.delete();
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Recommendation.DoesNotExist:
            return Response(status=status.HTTP_204_NO_CONTENT)

# Limited to GET PUT HEAD DELETE OPTIONS
class FriendshipViewSet(mixins.RetrieveModelMixin,
                    mixins.UpdateModelMixin,
                    viewsets.GenericViewSet):
    permission_classes = (permissions.IsAuthenticated, OwnerCanReadDelete)
    serializer_class = FriendshipSerializer
    queryset = Friendship.objects
    
    # GET
    def list(self, request):
        friends = Friendship.objects.filter(userOne=request.user).all()
        serializer = FriendshipSerializer(friends, many=True)
        return Response(serializer.data)
    
    # GET id
    def retrieve(self, request, pk=None):
        # convert fbid to django id
        socialuser = SocialAccount.objects.filter(uid=pk).first()
        if socialuser:
            friendship = getFriendship(request.user, socialuser.user.id)
            if friendship:
                # Serialize and return friendship
                serializer = FriendshipSerializer(friendship.first(), many=False)
                return Response(serializer.data)
        return Response({'detail': 'not found'}, status.HTTP_404_NOT_FOUND)
        
    # PUT id to change muted
    def update(self, request, pk=None, **kwargs):
        # convert fbid to django id
        socialuser = SocialAccount.objects.filter(uid=pk).first()
        if socialuser:
            friendship = getFriendship(request.user, socialuser.user.id)
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
        
        # See if user already exists
        try:
            self.user = self.serializer.validated_data['user']
            self.token_model.objects.get(user=self.user)
            firsttime = False
        except:
            firsttime = True
        
        # Login
        SocialLoginView.login(self)

        # Update friends
        getCurrentFriendsListFromFacebook(self.user)

        # If the user was just created
        if firsttime:
            generatePromptsForNewUser(self.user)


def deploy(request):
    if request.method != 'POST':
        response = HttpResponse('Invalid method')
        response.status_code = 405
        return response

    try:
        valid_signature = 'sha1=' + hmac.new(os.environ['GitHubWebHookSecret'].encode(), request.body, 'sha1').hexdigest()
        request_signature = request.environ['HTTP_X_HUB_SIGNATURE']

        if not hmac.compare_digest(valid_signature, request_signature):
            response = HttpResponse('Keys do not match:\n' + valid_signature + '\n' + request_signature)
            response.status_code = 401
            return response
    except KeyError:
        response = HttpResponse('Missing key')
        response.status_code = 400
        return response

    # Signature is valid

    json_data = json.loads(request.body.decode())

    try:
        if json_data['ref'].find('master') == -1:
            response = HttpResponse('Not master branch')
            response.status_code = 200
            return response
    except KeyError:
        response = HttpResponse('Can\'t find branch data')
        response.status_code = 400
        return response

    subprocess.Popen(['bash', '/home/dominic/scripts/deploy.sh'])

    response = HttpResponse('Deployed')
    response.status_code = 200
    return response


def error(request):
    log = subprocess.check_output(['bash', '/home/dominic/scripts/apache_error_log.sh'])
    response = HttpResponse('<html><head></head><body><pre>' + log.decode() + '</pre></body></html>')
    response.status_code = 200
    return response
