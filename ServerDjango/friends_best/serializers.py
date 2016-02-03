import json

from rest_framework import serializers

from friends_best.models import *
from friends_best.services import *
from django.contrib.auth.models import User
from allauth.socialaccount.models import SocialAccount


import hashlib # For SHA-256 Encoding
import base64


class UserSerializer(serializers.ModelSerializer):
    
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
    
    class Meta:
        model = Prompt
        fields = '__all__'

    
class RecommendationTagSerializer(serializers.ModelSerializer):

    class Meta:
        model = RecommendationTag
        fields = '__all__'


class QueryTagSerializer(serializers.ModelSerializer):

    def to_representation(self, instance):
        warning('this works')
        query_dict = dict()
        tag_list = QueryTag.objects.all().values('query', 'tag',)
        for tag in tag_list:
            qid = tag['query']
            if qid in query_dict:
                query_dict[qid]['tags'].append(tag['tag'])
            else:
                query_dict[qid] = {'id': qid, 'tags': [tag['tag']]}
        query_serialized = json.dumps(list(query_dict.values()))
        return query_serialized

    class Meta:
        model = QueryTag
        fields = ('query', 'tag',)


class TextThingSerializer(serializers.ModelSerializer):

    class Meta:
        model = TextThing
        fields = '__all__'


class RecommendationSerializer(serializers.Serializer):
    user = serializers.CharField(max_length=50)
    description = serializers.CharField(max_length=200)
    comments = serializers.CharField(max_length=500)
    tags = RecommendationTagSerializer(many=True)

    def to_internal_value(self, data):
        return data

    # data -Recommendation object new comment
    def to_representation(self, data):
        rec_tags = RecommendationTag.objects.filter(recommendation=data).values('tag')
        text_thing = TextThing.objects.filter(thing=data.thing).get()

        recommendation_json = {
            'id': data.id,
            'user': data.user.first_name,
            'description': text_thing.description,
            'comments': data.comments,
            'tags': [rt['tag'] for rt in rec_tags]
        }
        return recommendation_json

    def create(self, validated_data):
        user = validated_data.get('user')
        desc = validated_data.get('description')
        comments = validated_data.get('comments')
        tags = validated_data.get('tags')
        rec_id = createRecommendation(user, desc, comments, *tags)
        return Recommendation.objects.filter(id=rec_id).get()

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
    user = UserSerializer
    tags = QueryTagSerializer(many=True)

    def to_internal_value(self, data):
        return data

    def to_representation(self, query):
        solutions = getQuerySolutions(query.id)
        solution_collection = {
            'id':query.id,
            'tags':solutions['tags'],
            'tagstring':query.tagstring,
            'solutions': [],
            'timestamp': query.timestamp,
            'taghash': query.taghash
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
        
    def update(self, instance, validated_data):
	    return
    

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
        fields = ('id', 'tags', 'tagstring', 'user', 'timestamp', )


class PinSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Pin
        fields = '__all__'
