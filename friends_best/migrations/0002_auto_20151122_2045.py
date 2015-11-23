# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('friends_best', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='friend',
            name='friend',
            field=models.ForeignKey(related_name='friend_set', default='CAA324l2jlk4j3242', to='friends_best.User'),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='friend',
            name='user',
            field=models.ForeignKey(to='friends_best.User', related_name='user_set'),
        ),
        migrations.AlterUniqueTogether(
            name='friend',
            unique_together=set([('user', 'friend')]),
        ),
        migrations.RemoveField(
            model_name='friend',
            name='friends',
        ),
    ]
