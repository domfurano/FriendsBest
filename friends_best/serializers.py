from rest_framework import serializers
from rest_framework.reverse import reverse
from friends_best.models import *


class UserSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ('token', 'userName', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('user-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }

class FriendsSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Friendship
        fields = ('userOne', 'userTwo', 'muted', 'links',)

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
        fields = ('user', 'timestamp', 'links',)

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
        fields = ('thingType', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('thing-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }


class RecommendationSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Recommendation
        fields = ('thing', 'user', 'comments', 'timestamp', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('recommendation-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }


class TextSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = TextThing
        fields = ('thing', 'content', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('text-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }


class PromptSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Prompt
        fields = ('user', 'query', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('prompt-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }


class RecommendationTagSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = RecommendationTag
        fields = ('recommendation', 'tag', 'lemma', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('recommendationTag-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }


class QueryTagSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = QueryTag
        fields = ('query', 'tag', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('queryTag-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }


class PinSerializer(serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Pin
        fields = ('thing', 'query', 'links',)

    def get_links(self, obj):
        request = self.context['request']
        return {
            'self': reverse('pin-detail',
                            kwargs={'pk': obj.pk}, request=request),
        }