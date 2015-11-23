from rest_framework import serializers
from rest_framework.reverse import reverse
from friends_best.models import *


class UserSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ('token', 'name', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('user-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }

class FriendsSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Friend
        fields = ('user', 'friend', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('friend-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }

class QuerySerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Query
        fields = ('user_id', 'timestamp', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('query-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }


class ThingSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Thing
        fields = ('type', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('thing-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }


class RecommendSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Recommend
        fields = ('thing_id', 'comments', 'timestamp', 'user_id', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('recommend-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }


class TextSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Text
        fields = ('text', 'thing_id', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('text-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }