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
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
                ('muted', models.BooleanField(default=False)),
            ],
        ),
        migrations.CreateModel(
            name='Pin',
            fields=[
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
            ],
        ),
        migrations.CreateModel(
            name='Prompt',
            fields=[
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
            ],
        ),
        migrations.CreateModel(
            name='Query',
            fields=[
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
                ('timestamp', models.DateTimeField(default=django.utils.timezone.now)),
            ],
        ),
        migrations.CreateModel(
            name='QueryTag',
            fields=[
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
                ('tag', models.CharField(max_length=20)),
                ('query', models.ForeignKey(to='friends_best.Query')),
            ],
        ),
        migrations.CreateModel(
            name='Recommendation',
            fields=[
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
                ('comments', models.TextField(max_length=500)),
                ('timestamp', models.DateTimeField(default=django.utils.timezone.now)),
            ],
        ),
        migrations.CreateModel(
            name='RecommendationTag',
            fields=[
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
                ('tag', models.CharField(max_length=25)),
                ('lemma', models.CharField(max_length=25)),
                ('recommendation', models.ForeignKey(to='friends_best.Recommendation')),
            ],
        ),
        migrations.CreateModel(
            name='Thing',
            fields=[
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
                ('thingType', models.CharField(choices=[('TEXT', 'Text')], default='TEXT', max_length=15)),
            ],
        ),
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
                ('userName', models.CharField(unique=True, max_length=50)),
                ('token', models.CharField(default='1', max_length=60)),
                ('facebookUserId', models.CharField(default='facebook1', max_length=60)),
            ],
        ),
        migrations.CreateModel(
            name='TextThing',
            fields=[
                ('thing', models.OneToOneField(primary_key=True, to='friends_best.Thing', serialize=False)),
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
            field=models.ForeignKey(to='friends_best.User', related_name='userOne_set'),
        ),
        migrations.AddField(
            model_name='friendship',
            name='userTwo',
            field=models.ForeignKey(to='friends_best.User', related_name='userTwo_set'),
        ),
        migrations.AlterUniqueTogether(
            name='friendship',
            unique_together=set([('userOne', 'userTwo')]),
        ),
    ]
