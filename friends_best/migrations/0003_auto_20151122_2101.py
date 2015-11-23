# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('friends_best', '0002_auto_20151122_2045'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='id',
            field=models.AutoField(serialize=False, auto_created=True, verbose_name='ID', primary_key=True, default=0),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='user',
            name='token',
            field=models.CharField(max_length=256),
        ),
    ]
