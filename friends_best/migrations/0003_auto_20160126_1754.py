# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('friends_best', '0002_auto_20160126_1657'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='recommendationtag',
            name='recommendation',
        ),
        migrations.AddField(
            model_name='recommendation',
            name='tags',
            field=models.ManyToManyField(to='friends_best.RecommendationTag'),
        ),
        migrations.AddField(
            model_name='recommendation',
            name='tagstring',
            field=models.TextField(default=''),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='recommendation',
            name='comments',
            field=models.TextField(),
        ),
    ]
