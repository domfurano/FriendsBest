# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('friends_best', '0003_auto_20151122_2101'),
    ]

    operations = [
        migrations.CreateModel(
            name='Friendship',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True, auto_created=True, verbose_name='ID')),
                ('muted', models.BooleanField(default=False)),
            ],
        ),
        migrations.CreateModel(
            name='Pin',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True, auto_created=True, verbose_name='ID')),
            ],
        ),
        migrations.CreateModel(
            name='Prompt',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True, auto_created=True, verbose_name='ID')),
            ],
        ),
        migrations.CreateModel(
            name='QueryTag',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True, auto_created=True, verbose_name='ID')),
                ('tag', models.CharField(max_length=20)),
            ],
        ),
        migrations.CreateModel(
            name='Recommendation',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True, auto_created=True, verbose_name='ID')),
                ('comments', models.TextField(max_length=500)),
                ('timestamp', models.DateTimeField(default=django.utils.timezone.now)),
            ],
        ),
        migrations.CreateModel(
            name='RecommendationTag',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True, auto_created=True, verbose_name='ID')),
                ('tag', models.CharField(max_length=25)),
                ('lemma', models.CharField(max_length=25)),
                ('recommendation', models.ForeignKey(to='friends_best.Recommendation')),
            ],
        ),
        migrations.CreateModel(
            name='TextThing',
            fields=[
                ('thing', models.OneToOneField(serialize=False, primary_key=True, to='friends_best.Thing')),
                ('description', models.TextField(max_length=200, unique=True)),
            ],
        ),
        migrations.AlterUniqueTogether(
            name='friend',
            unique_together=set([]),
        ),
        migrations.RemoveField(
            model_name='friend',
            name='friend',
        ),
        migrations.RemoveField(
            model_name='friend',
            name='user',
        ),
        migrations.RemoveField(
            model_name='recommend',
            name='thing_id',
        ),
        migrations.RemoveField(
            model_name='recommend',
            name='user_id',
        ),
        migrations.RemoveField(
            model_name='text',
            name='thing_id',
        ),
        migrations.RenameField(
            model_name='query',
            old_name='user_id',
            new_name='user',
        ),
        migrations.RemoveField(
            model_name='thing',
            name='type',
        ),
        migrations.RemoveField(
            model_name='user',
            name='name',
        ),
        migrations.AddField(
            model_name='thing',
            name='thingType',
            field=models.CharField(max_length=15, choices=[('TEXT', 'Text')], default='TEXT'),
        ),
        migrations.AddField(
            model_name='user',
            name='facebookUserId',
            field=models.CharField(max_length=60, default='facebook1'),
        ),
        migrations.AddField(
            model_name='user',
            name='userName',
            field=models.CharField(max_length=50, default=1, unique=True),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='query',
            name='timestamp',
            field=models.DateTimeField(default=django.utils.timezone.now),
        ),
        migrations.AlterField(
            model_name='user',
            name='token',
            field=models.CharField(max_length=60, default='1'),
        ),
        migrations.DeleteModel(
            name='Friend',
        ),
        migrations.DeleteModel(
            name='Recommend',
        ),
        migrations.DeleteModel(
            name='Text',
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
            model_name='querytag',
            name='query',
            field=models.ForeignKey(to='friends_best.Query'),
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
