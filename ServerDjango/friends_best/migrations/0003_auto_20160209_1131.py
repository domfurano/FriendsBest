# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('friends_best', '0002_auto_20160209_1130'),
    ]

    operations = [
        migrations.AlterField(
            model_name='prompt',
            name='query',
            field=models.OneToOneField(to='friends_best.Query'),
        ),
    ]
