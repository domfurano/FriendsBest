from django.contrib import admin

# Register your models here.
from .models import User
from .models import Friendship
from .models import Query
from .models import Thing
from .models import TextThing
from .models import Recommendation
from .models import Prompt
from .models import RecommendationTag
from .models import QueryTag
from .models import Pin


admin.site.register(User)
admin.site.register(Friendship)
admin.site.register(Query)
admin.site.register(Thing)
admin.site.register(TextThing)
admin.site.register(Recommendation)
admin.site.register(Prompt)
admin.site.register(RecommendationTag)
admin.site.register(QueryTag)
admin.site.register(Pin)

