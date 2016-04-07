# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('friends_best', '0005_auto_20160322_1552'),
    ]

    operations = [
        migrations.CreateModel(
            name='Notification',
            fields=[
                ('id', models.AutoField(verbose_name='ID', primary_key=True, serialize=False, auto_created=True)),
                ('query', models.ForeignKey(to='friends_best.Query')),
                ('recommendation', models.ForeignKey(to='friends_best.Recommendation')),
            ],
        ),
        migrations.AlterUniqueTogether(
            name='prompt',
            unique_together=set([('user', 'query')]),
        ),
        migrations.AlterUniqueTogether(
            name='notification',
            unique_together=set([('query', 'recommendation')]),
        ),
    ]
