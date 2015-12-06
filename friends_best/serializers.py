import json

from rest_framework import serializers

from friends_best.models import *
from friends_best.services import *


class UserSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = User
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
    
    class Meta:
        model = QueryTag
        fields = '__all__'


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

    # data -Recommendation object
    def to_representation(self, data):
        rec_tags = RecommendationTag.objects.filter(recommendation=data).values('tag')
        text_thing = TextThing.objects.filter(thing=data.thing).get()

        json_rep = {
            'id': data.id,
            'user': data.user.userName,
            'description': text_thing.description,
            'comments': data.comments,
            'tags': [rt['tag'] for rt in rec_tags]
        }
        return json_rep

    def create(self, validated_data):
        user = validated_data.get('user')
        desc = validated_data.get('description')
        comments = validated_data.get('comments')
        tags = validated_data.get('tags')
        rec_id = createRecommendation(user, desc, comments, *tags)
        recommendation = Recommendation.objects.filter(id=rec_id).get()
        warning('create {}'.format(recommendation))
        return recommendation

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

    class Meta:
        model = Query

    def to_internal_value(self, data):
        query = json.loads(data)

        if 'user' in query and 'tags' in query:
            return submitQuery(query['user'], query['tags'])
        return None

    def to_representation(self, query):
        user = query.user_id
        return getQueryHistory(user)


class PinSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Pin
        fields = '__all__'
