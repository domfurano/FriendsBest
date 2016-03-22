from django.db import models
import datetime
from django.utils import timezone
from django.contrib.auth.models import User

# class User(models.Model):
#     userName = models.CharField(max_length=50, unique=True)
#     token = models.CharField(max_length=60, default="1")
#     facebookUserId = models.CharField(max_length=60, default="facebook1")
#
#     def __str__(self):
#         return self.userName


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


class Thing(models.Model):
   TEXT = 'TEXT'
   PLACE = 'PLACE'
   URL = 'URL'
   THING_TYPE_CHOICES = (
       (TEXT, 'Text'),
       (PLACE, 'Place'),
       (URL, 'Url'),
   )
   thingType = models.CharField(max_length=15, choices=THING_TYPE_CHOICES, default=TEXT)

   def __str__(self):
       return "pk:%s - thingType:%s" % (self.pk, self.thingType)


class TextThing(models.Model):
   thing = models.OneToOneField(Thing, primary_key=True)
   description = models.TextField(max_length=200, unique=True)

   def __str__(self):
       return "thingID:%s, content:%s" % (self.thing.pk, self.description)


class PlaceThing(models.Model):
   thing = models.OneToOneField(Thing, primary_key=True)
   placeId = models.TextField(max_length=200, unique=True)

   def __str__(self):
       return "thingID:%s, placeId:%s" % (self.thing.pk, self.placeId)


class UrlThing(models.Model):
   thing = models.OneToOneField(Thing, primary_key=True)
   url = models.TextField(max_length=400, unique=True)

   def __str__(self):
       return "thingID:%s, url:%s" % (self.thing.pk, self.url)


class Tag(models.Model):
   tag = models.CharField(max_length=25, unique=True)
   lemma = models.CharField(max_length=25, unique=True)

   def save(self, *args, **kwargs):
       if not self.lemma:
           self.lemma = self.tag
       super(Tag, self).save(*args, **kwargs)

   def __str__(self):
       return "%s" % (self.tag)


class Recommendation(models.Model):
   thing = models.ForeignKey(Thing)
   user = models.ForeignKey(User)
   comments = models.TextField()
   tags = models.ManyToManyField(Tag)
   timestamp = models.DateTimeField(default=timezone.now)
   tagstring = models.TextField()

   def __str__(self):
       return "user:%s, thing:%s, comments:%s" % (self.user, self.thing, self.comments)

class Query(models.Model):
   user = models.ForeignKey(User)
   tags = models.ManyToManyField(Tag)
   timestamp = models.DateTimeField(default=timezone.now)
   tagstring = models.TextField()
   taghash = models.TextField()
   urgent = models.BooleanField(default=False)

   def __str__(self):
       return "%s at %s" % (self.user, self.timestamp)

   class Meta:
       unique_together = (("user", "taghash"),)

class Prompt(models.Model):
   user = models.ForeignKey(User)  # the user who the prompt is for (not the user who made the associated query)
   query = models.ForeignKey(Query)  # we can get the user's id from the query

   def __str__(self):
       return "forUser:%s, fromQuery:%s" % (self.user, self.query)


# TODO: do we want to associate these with specific recommendations rather than with Things???
class Pin(models.Model):
   thing = models.ForeignKey(Thing)
   query = models.ForeignKey(Query)

   def __str__(self):
       return "thing:%s, query:%s" % (self.thing, self.query)

   class Meta:
       unique_together = (("thing", "query"),)




# allows users to listen for queries which include a specified tag (from any user)
# TODO: should we store a single tag for multiple subscriptions, or just use a list of tags???
class Subscription(models.Model):
   user = models.ForeignKey(User)
   tag = models.ForeignKey(Tag)

   def __str__(self):
       return "user:%s, tag:%s" % (self.user, self.tag)

   class Meta:
       unique_together = (("user", "tag"),)


# TODO: need to implement logic in services
class Accolade(models.Model):
   user = models.ForeignKey(User)
   recommendation = models.ForeignKey(Recommendation)

   def __str__(self):
       return "user:%s, recommendation:%s" % (self.user, self.recommendation)

   class Meta:
       unique_together = (("user", "recommendation"),)




