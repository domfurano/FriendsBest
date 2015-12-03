import json
from logging import warning, error

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

    
class RecommendationSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Recommendation
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


class QuerySerializer(serializers.ModelSerializer):

    class Meta:
        model = Query

    def to_internal_value(self, data):
        return submitQuery(int(data['user']), data['tags'])

    def to_representation(self, query):
        query_obj = super(QuerySerializer, self).to_representation(query)
        query_obj['tags'] = []
        for tag in QueryTag.objects.filter(query=query_obj['id']):
            query_obj['tags'].append(tag.tag)
        return query_obj


class PinSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Pin
        fields = '__all__'
