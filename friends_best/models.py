from django.db import models


class User(models.Model):
    token = models.CharField(max_length=256)
    name = models.CharField(max_length=30)


class Friend(models.Model):
    user = models.ForeignKey(User, related_name='user_set')
    friend = models.ForeignKey(User, related_name='friend_set')

    class Meta:
        unique_together = (('user', 'friend'), )

class Query(models.Model):
    user_id = models.ForeignKey(User)
    timestamp = models.DateTimeField()


class Thing(models.Model):
    type = models.IntegerField()


class Recommend(models.Model):
    thing_id = models.ForeignKey(Thing)
    comments = models.CharField(max_length=1024)
    timestamp = models.DateTimeField()
    user_id = models.ForeignKey(User)


class Text(models.Model):
    text = models.CharField(max_length=1000)
    thing_id = models.ForeignKey(Thing)
