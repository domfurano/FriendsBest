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
            #'friend': '' if prompt.isAnonymous else UserSerializer(prompt.query.user).data,
            'friend': UserSerializer(prompt.query.user).data,
            'tags': [t.tag for t in prompt.query.tags.all()],
            'tagstring': prompt.query.tagstring,
            # could also be a good place to send articles like "a," "an"
            # but we'll need some good NLP
            'article': 'a',
            'urgent': prompt.query.urgent  # this seems to be causing a problem (not sure why)
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


class UrlThingSerializer(serializers.ModelSerializer):

    class Meta:
        model = UrlThing
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
            'detail': detail,
            'type': recommendation.thing.thingType,
            'comments': recommendation.comments,
            'tags': [rt.tag for rt in rec_tags],
            'user': UserSerializer(recommendation.user).data
        }
        return recommendation_json

    def create(self, validated_data):
        user = validated_data.get('user')
        detail = validated_data.get('detail')
        comments = validated_data.get('comments')
        tags = validated_data.get('tags')
        thingtype = validated_data.get('type')
        return createRecommendation(user, detail, thingtype, comments, *tags)

    # Return - validated data in a dictionary
    def validate(self, data):
        if 'user' not in data:
            raise serializers.ValidationError("user is missing")
        elif 'detail' not in data:
            raise serializers.ValidationError("detail is missing")
        elif 'type' not in data:
            raise serializers.ValidationError("type is missing")
        elif 'comments' not in data:
            raise serializers.ValidationError("comments are missing")
        elif 'tags' not in data:
            raise serializers.ValidationError("tags are missing")

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
            'accessed': query.timestamp,
            'taghash': query.taghash,
        }
        
        newtotal = 0;
        for sol in solutions['solutions']:
            recommendations = []
            for rwf in sol.recommendationsWithFlags:
                rec = rwf.recommendation
                if isFriendsWith(query.user, rec.user) or query.user == rec.user:
                    recommendations.append({"id": rec.id, "comment": rec.comments, "isNew": rwf.isNew, "user": UserSerializer(rec.user).data})
                else:
                    recommendations.append({"id": rec.id, "comment": rec.comments, "isNew": rwf.isNew})
            solution_collection['solutions'].append({
                'detail': sol.detail,
                'type': sol.solutionType,
                'recommendations': recommendations,
                'isPinned': sol.isPinned,
                'notifications': sol.totalNewRecommendations
            })
            newtotal += sol.totalNewRecommendations
            
        solution_collection['notifications'] = newtotal
        
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
