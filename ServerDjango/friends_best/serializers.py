import json

from rest_framework import serializers

from friends_best.models import *
from friends_best.services import *
from django.contrib.auth.models import User
from allauth.socialaccount.models import SocialAccount


import hashlib # For SHA-256 Encoding
import base64


class UserSerializer(serializers.ModelSerializer):
    
    def to_representation(self, user):
        
        account = SocialAccount.objects.filter(user=user).first()
        
        return {
            'id': user.id,
            'name': user.first_name + " " + user.last_name,
            'email': user.email,
            'fbid': account.uid
        }

    
    class Meta:
        model = User
        fields = '__all__'

class UserSocialSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = SocialAccount
        fields = '__all__'


class FriendsSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Friendship
        fields = '__all__'

    
class ThingSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Thing
        fields = '__all__'


class TextSerializer(serializers.ModelSerializer):

    class Meta:
        model = TextThing
        fields = '__all__'


class PromptSerializer(serializers.ModelSerializer):
    
    def to_representation(self, prompt):
        
        account = SocialAccount.objects.filter(user=prompt.query.user).first()
        
        return {
            'id': prompt.id,
            # Copied from FriendshipSerializer
            'friend': {
                'fbid': account.uid,
                'id': prompt.query.user.id,
                'name': prompt.query.user.first_name + " " + prompt.query.user.last_name
            },
            'tags': [t.tag for t in prompt.query.tags.all()],
            'tagstring': prompt.query.tagstring,
            # could also be a good place to send articles like "a," "an"
            # but we'll need some good NLP
            'article': 'a'
        }
    
    class Meta:
        model = Prompt
        fields = '__all__'
        depth = 1
        
class FriendshipSerializer(serializers.ModelSerializer):
    
    def to_representation(self, friend):
        account = SocialAccount.objects.filter(user=friend.userTwo).first()
        return {
            'fbid': account.uid,
            'id': friend.userTwo.id,
            'name': friend.userTwo.first_name + " " + friend.userTwo.last_name,
            'muted': friend.muted
        }
        
    class Meta:
        model = Friendship
        fields = '__all__'
        depth = 1

class TagSerializer(serializers.ModelSerializer):

    def to_representation(self, instance):
        query_dict = dict()
        tag_list = Tag.objects.all().values('query', 'tag',)
        for tag in tag_list:
            qid = tag['query']
            if qid in query_dict:
                query_dict[qid]['tags'].append(tag['tag'])
            else:
                query_dict[qid] = {'id': qid, 'tags': [tag['tag']]}
        query_serialized = json.dumps(list(query_dict.values()))
        return query_serialized

    class Meta:
        model = Tag
        fields = ('tag',)


class TextThingSerializer(serializers.ModelSerializer):

    class Meta:
        model = TextThing
        fields = '__all__'


class RecommendationSerializer(serializers.Serializer):
    user = serializers.CharField(max_length=50)
    description = serializers.CharField(max_length=200)
    comments = serializers.CharField(max_length=500)
    tags = TagSerializer(many=True)

    def to_internal_value(self, data):
        return data

    # data -Recommendation object new comment
    def to_representation(self, recommendation):
        rec_tags = recommendation.tags.all()
        text_thing = TextThing.objects.filter(thing=recommendation.thing).get()

        recommendation_json = {
            'id': recommendation.id,
            'description': text_thing.description,
            'comments': recommendation.comments,
            'tags': [rt.tag for rt in rec_tags]
        }
        return recommendation_json

    def create(self, validated_data):
        user = validated_data.get('user')
        desc = validated_data.get('description')
        comments = validated_data.get('comments')
        tags = validated_data.get('tags')
        return createRecommendation(user, desc, comments, *tags)

    # Return - validated data in a dictionary
    def validate(self, data):
        if 'user' not in data:
            raise serializers.ValidationError("user is missing")
        elif 'description' not in data:
            raise serializers.ValidationError("description is missing")
        elif 'comments' not in data:
            raise serializers.ValidationError("comments are missing")
        elif 'tags' not in data:
            raise serializers.ValidationError("missing tags")

        user = User.objects.filter(id=data['user'])
        if not user.exists():
            raise serializers.ValidationError("user doesn't exist")

        data["id"] = user.get().id
        return data

    class Meta:
        model = Recommendation
        fields = ('id', 'user', 'description', 'comments', 'tags',)


class QuerySerializer(serializers.ModelSerializer):
    #user = UserSerializer
    tags = TagSerializer(many=True)

    def to_internal_value(self, data):
        return data

    def to_representation(self, query):
        
        # Get a solutions object to return
        solutions = getQuerySolutions(query)
        solution_collection = {
            'id':query.id,
            'tags':solutions['tags'],
            'tagstring':query.tagstring,
            'solutions': [],
            'timestamp': query.timestamp,
            'taghash': query.taghash,
        }
        for sol in solutions['solutions']:
            name = sol.description
            recommendations = [rec for rec in sol.userComments]
            solution_collection['solutions'].append({'name': name, 'recommendation': recommendations})
        return solution_collection

    def create(self, validated_data):    
        user = validated_data.get('user')
        tags = validated_data.get('tags')
        q = submitQuery(user, *tags)
        return q

    def validate(self, data):
        if 'user' not in data:
            raise serializers.ValidationError('No user provided')
        elif 'tags' not in data:
            raise serializers.ValidationError('No tags provided')

        user = User.objects.filter(id=data['user'])
        if not user.exists():
            raise serializers.ValidationError('User does not exist')

        return data

    class Meta:
        model = Query
        fields = ('id', 'tags', )

class PinSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Pin
        fields = '__all__'
