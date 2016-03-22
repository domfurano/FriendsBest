# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('friends_best', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='prompt',
            name='query',
            field=models.ForeignKey(unique=True, to='friends_best.Query'),
        ),
    ]
