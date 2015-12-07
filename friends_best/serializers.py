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

    def to_representation(self, instance):
        query_dict = dict()
        tag_list = QueryTag.objects.all().values('query', 'tag')
        for tag in tag_list:
            qid = tag['query']
            if qid in query_dict:
                query_dict[qid].append(tag['tag'])
            else:
                query_dict[qid] = [tag['tag']]
        return query_dict

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

    # data -Recommendation object
    def to_representation(self, data):
        rec_tags = RecommendationTag.objects.filter(recommendation=data).values('tag')
        text_thing = TextThing.objects.filter(thing=data.thing).get()

        recommendation_json = {
            'id': data.id,
            'user': data.user.userName,
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
    comment = serializers.CharField(max_length=500)

    def to_internal_value(self, data):
        return data

    def to_representation(self, query):
        solution = getQuerySolutions(query.id)
        user = query.user.userName
        solution_json = dict()
        for sol in solution:
            user_name = sol.userComments['userComments']
            solution_json[sol.description] = user_name
        return solution_json

    def create(self, validated_data):
        user = validated_data.get('user')
        tags = validated_data.get('tags')
        qid = submitQuery(user, *tags)
        return Query.objects.filter(id=qid).get()

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
        fields = ('id', 'tags', 'user', 'comment', )


class PinSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Pin
        fields = '__all__'
