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
            'name': user.first_name + " " + user.last_name,
            'id': account.uid
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
            'friend': UserSerializer(prompt.query.user).data,
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
        user = UserSerializer(friend.userTwo).data
        user["muted"] = friend.muted
        return user

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
        
        detail = ""
        if recommendation.thing.thingType.lower() == 'text':
            thing = TextThing.objects.filter(thing=recommendation.thing).get()
            detail = thing.description
        if recommendation.thing.thingType.lower() == 'place':
            thing = PlaceThing.objects.filter(thing=recommendation.thing).get()
            detail = thing.placeId

        recommendation_json = {
            'id': recommendation.id,
            'thing': thing,
            'thingtype': recommendation.thing.thingType,
            'comments': recommendation.comments,
            'tags': [rt.tag for rt in rec_tags],
            'user': UserSerializer(recommendation.user).data
        }
        return recommendation_json

    def create(self, validated_data):
        user = validated_data.get('user')
        desc = validated_data.get('description')
        comments = validated_data.get('comments')
        tags = validated_data.get('tags')
        thing = validated_data.get('thing')
        return createRecommendation(user, desc, comments, *tags, thing)

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
            recommendations = []
            for rec in sol.recommendations:
                if isFriendsWith(query.user, rec.user) or query.user == rec.user:
                    recommendations.append({"comment": rec.comments, "user": UserSerializer(rec.user).data})
                else:
                    recommendations.append({"comment": rec.comments})
            solution_collection['solutions'].append({
                'detail': sol.detail,
                'solutionType': sol.solutionType,
                'recommendations': recommendations
            })
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
