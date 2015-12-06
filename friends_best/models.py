from django.db import models
import datetime
from django.utils import timezone


class User(models.Model):
    userName = models.CharField(max_length=50, unique=True)
    token = models.CharField(max_length=60, default="1")
    facebookUserId = models.CharField(max_length=60, default="facebook1")

    def __str__(self):
        return self.userName


class Friendship(models.Model):
    userOne = models.ForeignKey(User, related_name='userOne_set')
    userTwo = models.ForeignKey(User, related_name='userTwo_set')
    muted = models.BooleanField(default=False)
    
    class Meta:
        unique_together = (("userOne", "userTwo"),)

    def save(self, *args, **kwargs):
        if self.userOne != self.userTwo:
            super(Friendship, self).save(*args, **kwargs)
        else:
            return "a user cannot be his/her own friend!"

    def __str__(self):
        return "%s -> %s " % (self.userOne, self.userTwo)


class Query(models.Model):
    user = models.ForeignKey(User)
    timestamp = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return "%s at %s" % (self.user, self.timestamp)


class Thing(models.Model):
    TEXT = 'TEXT'
    THING_TYPE_CHOICES = (
        (TEXT, 'Text'),
    )
    thingType = models.CharField(max_length=15, choices=THING_TYPE_CHOICES, default=TEXT)

    def __str__(self):
        return "pk:%s - thingType:%s" % (self.pk, self.thingType)


class TextThing(models.Model):
    thing = models.OneToOneField(Thing, primary_key=True)
    description = models.TextField(max_length=200, unique=True)

    def __str__(self):
        return "thingID:%s, content:%s" % (self.thing.pk, self.description)


class Recommendation(models.Model):
    thing = models.ForeignKey(Thing)
    user = models.ForeignKey(User)
    comments = models.TextField(max_length=500)
    timestamp = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return "user:%s, thing:%s, comments:%s" % (self.user, self.thing, self.comments)


class Prompt(models.Model):
    user = models.ForeignKey(User)
    query = models.ForeignKey(Query)  # we can get the user's id from the query

    def __str__(self):
        return "forUser:%s, fromQuery:%s" % (self.user, self.query)


class RecommendationTag(models.Model):
    recommendation = models.ForeignKey(Recommendation)
    tag = models.CharField(max_length=25)
    lemma = models.CharField(max_length=25)
    
    def save(self, *args, **kwargs):
        if not self.lemma:
            self.lemma = self.tag
        super(RecommendationTag, self).save(*args, **kwargs)
        
    def __str__(self):
        return "tag:%s, recommendation:%s)" % (self.tag, self.recommendation)


class QueryTag(models.Model):
    query = models.ForeignKey(Query)
    tag = models.CharField(max_length=20)

    def __str__(self):
        return "tag:%s, query:%s" % (self.tag, self.query)


class Pin(models.Model):
    thing = models.ForeignKey(Thing)
    query = models.ForeignKey(Query)

    def __str__(self):
        return "thing:%s, query:%s" % (self.thing, self.query)




