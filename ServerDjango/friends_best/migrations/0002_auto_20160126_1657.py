# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('friends_best', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='query',
            name='taghash',
            field=models.TextField(),
        ),
    ]
