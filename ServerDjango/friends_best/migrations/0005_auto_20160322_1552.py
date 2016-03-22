# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('friends_best', '0004_auto_20160209_1643'),
    ]

    operations = [
        migrations.CreateModel(
            name='Accolade',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True, auto_created=True, verbose_name='ID')),
                ('recommendation', models.ForeignKey(to='friends_best.Recommendation')),
                ('user', models.ForeignKey(to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='PlaceThing',
            fields=[
                ('thing', models.OneToOneField(primary_key=True, serialize=False, to='friends_best.Thing')),
                ('placeId', models.TextField(max_length=200, unique=True)),
            ],
        ),
        migrations.CreateModel(
            name='Subscription',
            fields=[
                ('id', models.AutoField(serialize=False, primary_key=True, auto_created=True, verbose_name='ID')),
                ('tag', models.ForeignKey(to='friends_best.Tag')),
                ('user', models.ForeignKey(to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='UrlThing',
            fields=[
                ('thing', models.OneToOneField(primary_key=True, serialize=False, to='friends_best.Thing')),
                ('url', models.TextField(max_length=400, unique=True)),
            ],
        ),
        migrations.AddField(
            model_name='query',
            name='urgent',
            field=models.BooleanField(default=False),
        ),
        migrations.AlterField(
            model_name='thing',
            name='thingType',
            field=models.CharField(default='TEXT', choices=[('TEXT', 'Text'), ('PLACE', 'Place'), ('URL', 'Url')], max_length=15),
        ),
        migrations.AlterUniqueTogether(
            name='pin',
            unique_together=set([('thing', 'query')]),
        ),
        migrations.AlterUniqueTogether(
            name='subscription',
            unique_together=set([('user', 'tag')]),
        ),
        migrations.AlterUniqueTogether(
            name='accolade',
            unique_together=set([('user', 'recommendation')]),
        ),
    ]
