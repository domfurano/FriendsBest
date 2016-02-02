# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
import django.utils.timezone
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Friendship',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('muted', models.BooleanField(default=False)),
                ('userOne', models.ForeignKey(to=settings.AUTH_USER_MODEL, related_name='userOne_set')),
                ('userTwo', models.ForeignKey(to=settings.AUTH_USER_MODEL, related_name='userTwo_set')),
            ],
        ),
        migrations.CreateModel(
            name='Pin',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
            ],
        ),
        migrations.CreateModel(
            name='Prompt',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
            ],
        ),
        migrations.CreateModel(
            name='Query',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('timestamp', models.DateTimeField(default=django.utils.timezone.now)),
                ('tagstring', models.TextField()),
                ('taghash', models.BigIntegerField()),
            ],
        ),
        migrations.CreateModel(
            name='QueryTag',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('tag', models.CharField(max_length=20)),
            ],
        ),
        migrations.CreateModel(
            name='Recommendation',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('comments', models.TextField(max_length=500)),
                ('timestamp', models.DateTimeField(default=django.utils.timezone.now)),
            ],
        ),
        migrations.CreateModel(
            name='RecommendationTag',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('tag', models.CharField(max_length=25)),
                ('lemma', models.CharField(max_length=25)),
                ('recommendation', models.ForeignKey(to='friends_best.Recommendation')),
            ],
        ),
        migrations.CreateModel(
            name='Thing',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('thingType', models.CharField(default='TEXT', max_length=15, choices=[('TEXT', 'Text')])),
            ],
        ),
        migrations.CreateModel(
            name='TextThing',
            fields=[
                ('thing', models.OneToOneField(to='friends_best.Thing', primary_key=True, serialize=False)),
                ('description', models.TextField(max_length=200, unique=True)),
            ],
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
            field=models.ManyToManyField(to='friends_best.QueryTag'),
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
