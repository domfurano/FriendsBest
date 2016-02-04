# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
from django.conf import settings
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Friendship',
            fields=[
                ('id', models.AutoField(verbose_name='ID', auto_created=True, serialize=False, primary_key=True)),
                ('muted', models.BooleanField(default=False)),
                ('userOne', models.ForeignKey(to=settings.AUTH_USER_MODEL, related_name='userOne_set')),
                ('userTwo', models.ForeignKey(to=settings.AUTH_USER_MODEL, related_name='userTwo_set')),
            ],
        ),
        migrations.CreateModel(
            name='Pin',
            fields=[
                ('id', models.AutoField(verbose_name='ID', auto_created=True, serialize=False, primary_key=True)),
            ],
        ),
        migrations.CreateModel(
            name='Prompt',
            fields=[
                ('id', models.AutoField(verbose_name='ID', auto_created=True, serialize=False, primary_key=True)),
            ],
        ),
        migrations.CreateModel(
            name='Query',
            fields=[
                ('id', models.AutoField(verbose_name='ID', auto_created=True, serialize=False, primary_key=True)),
                ('timestamp', models.DateTimeField(default=django.utils.timezone.now)),
                ('tagstring', models.TextField()),
                ('taghash', models.TextField()),
            ],
        ),
        migrations.CreateModel(
            name='Recommendation',
            fields=[
                ('id', models.AutoField(verbose_name='ID', auto_created=True, serialize=False, primary_key=True)),
                ('comments', models.TextField()),
                ('timestamp', models.DateTimeField(default=django.utils.timezone.now)),
                ('tagstring', models.TextField()),
            ],
        ),
        migrations.CreateModel(
            name='Tag',
            fields=[
                ('id', models.AutoField(verbose_name='ID', auto_created=True, serialize=False, primary_key=True)),
                ('tag', models.CharField(unique=True, max_length=25)),
                ('lemma', models.CharField(unique=True, max_length=25)),
            ],
        ),
        migrations.CreateModel(
            name='Thing',
            fields=[
                ('id', models.AutoField(verbose_name='ID', auto_created=True, serialize=False, primary_key=True)),
                ('thingType', models.CharField(choices=[('TEXT', 'Text')], max_length=15, default='TEXT')),
            ],
        ),
        migrations.CreateModel(
            name='TextThing',
            fields=[
                ('thing', models.OneToOneField(to='friends_best.Thing', serialize=False, primary_key=True)),
                ('description', models.TextField(unique=True, max_length=200)),
            ],
        ),
        migrations.AddField(
            model_name='recommendation',
            name='tags',
            field=models.ManyToManyField(to='friends_best.Tag'),
        ),
        migrations.AddField(
            model_name='recommendation',
            name='thing',
            field=models.ForeignKey(to='friends_best.Thing'),
        ),
        migrations.AddField(
            model_name='recommendation',
            name='user',
            field=models.ForeignKey(to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='query',
            name='tags',
            field=models.ManyToManyField(to='friends_best.Tag'),
        ),
        migrations.AddField(
            model_name='query',
            name='user',
            field=models.ForeignKey(to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='prompt',
            name='query',
            field=models.ForeignKey(to='friends_best.Query'),
        ),
        migrations.AddField(
            model_name='prompt',
            name='user',
            field=models.ForeignKey(to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='pin',
            name='query',
            field=models.ForeignKey(to='friends_best.Query'),
        ),
        migrations.AddField(
            model_name='pin',
            name='thing',
            field=models.ForeignKey(to='friends_best.Thing'),
        ),
        migrations.AlterUniqueTogether(
            name='query',
            unique_together=set([('user', 'taghash')]),
        ),
        migrations.AlterUniqueTogether(
            name='friendship',
            unique_together=set([('userOne', 'userTwo')]),
        ),
    ]
