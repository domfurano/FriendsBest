# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Friendship',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('muted', models.BooleanField(default=False)),
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
            ],
        ),
        migrations.CreateModel(
            name='QueryTag',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('tag', models.CharField(max_length=20)),
                ('query', models.ForeignKey(to='friends_best.Query')),
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
                ('thingType', models.CharField(choices=[('TEXT', 'Text')], max_length=15, default='TEXT')),
            ],
        ),
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('userName', models.CharField(unique=True, max_length=50)),
                ('token', models.CharField(max_length=60, default='1')),
                ('facebookUserId', models.CharField(max_length=60, default='facebook1')),
            ],
        ),
        migrations.CreateModel(
            name='TextThing',
            fields=[
                ('thing', models.OneToOneField(to='friends_best.Thing', primary_key=True, serialize=False)),
                ('description', models.TextField(unique=True, max_length=200)),
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
            field=models.ForeignKey(to='friends_best.User'),
        ),
        migrations.AddField(
            model_name='query',
            name='user',
            field=models.ForeignKey(to='friends_best.User'),
        ),
        migrations.AddField(
            model_name='prompt',
            name='query',
            field=models.ForeignKey(to='friends_best.Query'),
        ),
        migrations.AddField(
            model_name='prompt',
            name='user',
            field=models.ForeignKey(to='friends_best.User'),
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
        migrations.AddField(
            model_name='friendship',
            name='userOne',
            field=models.ForeignKey(related_name='userOne_set', to='friends_best.User'),
        ),
        migrations.AddField(
            model_name='friendship',
            name='userTwo',
            field=models.ForeignKey(related_name='userTwo_set', to='friends_best.User'),
        ),
        migrations.AlterUniqueTogether(
            name='friendship',
            unique_together=set([('userOne', 'userTwo')]),
        ),
    ]
