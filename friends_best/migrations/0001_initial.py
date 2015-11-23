# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Friend',
            fields=[
                ('id', models.AutoField(primary_key=True, auto_created=True, verbose_name='ID', serialize=False)),
                ('friends', models.ManyToManyField(related_name='_friend_friends_+', to='friends_best.Friend')),
            ],
        ),
        migrations.CreateModel(
            name='Query',
            fields=[
                ('id', models.AutoField(primary_key=True, auto_created=True, verbose_name='ID', serialize=False)),
                ('timestamp', models.DateTimeField()),
            ],
        ),
        migrations.CreateModel(
            name='Recommend',
            fields=[
                ('id', models.AutoField(primary_key=True, auto_created=True, verbose_name='ID', serialize=False)),
                ('comments', models.CharField(max_length=1024)),
                ('timestamp', models.DateTimeField()),
            ],
        ),
        migrations.CreateModel(
            name='Text',
            fields=[
                ('id', models.AutoField(primary_key=True, auto_created=True, verbose_name='ID', serialize=False)),
                ('text', models.CharField(max_length=1000)),
            ],
        ),
        migrations.CreateModel(
            name='Thing',
            fields=[
                ('id', models.AutoField(primary_key=True, auto_created=True, verbose_name='ID', serialize=False)),
                ('type', models.IntegerField()),
            ],
        ),
        migrations.CreateModel(
            name='User',
            fields=[
                ('token', models.CharField(primary_key=True, max_length=256, serialize=False)),
                ('name', models.CharField(max_length=30)),
            ],
        ),
        migrations.AddField(
            model_name='text',
            name='thing_id',
            field=models.ForeignKey(to='friends_best.Thing'),
        ),
        migrations.AddField(
            model_name='recommend',
            name='thing_id',
            field=models.ForeignKey(to='friends_best.Thing'),
        ),
        migrations.AddField(
            model_name='recommend',
            name='user_id',
            field=models.ForeignKey(to='friends_best.User'),
        ),
        migrations.AddField(
            model_name='query',
            name='user_id',
            field=models.ForeignKey(to='friends_best.User'),
        ),
        migrations.AddField(
            model_name='friend',
            name='user',
            field=models.OneToOneField(related_name='friend', to='friends_best.User'),
        ),
    ]
