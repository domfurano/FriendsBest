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
# admin.site.register(Query)
# admin.site.register(Thing)
# admin.site.register(TextThing)
# admin.site.register(Recommendation)
admin.site.register(Prompt)
# admin.site.register(RecommendationTag)
admin.site.register(QueryTag)
admin.site.register(Pin)


class QueryTagInline(admin.TabularInline):
    model = QueryTag
    extra = 5


class QueryAdmin(admin.ModelAdmin):
    fieldsets = [
        (None, {'fields': ['user']}),
    ]
    inlines = [QueryTagInline]
admin.site.register(Query, QueryAdmin)

class RecommendationTagAdmin(admin.ModelAdmin):
    fieldsets = [
        (None, {'fields': ['recommendation']}),
        (None, {'fields': ['tag']}),
    ]
admin.site.register(RecommendationTag, RecommendationTagAdmin)


class RecommendationTagInline(admin.TabularInline):
    model = RecommendationTag
    extra = 5
    fields = ('tag',)


class RecommendationAdmin(admin.ModelAdmin):
    fieldsets = [
        (None, {'fields': ['thing']}),
        (None, {'fields': ['user']}),
        (None, {'fields': ['comments']}),
        (None, {'fields': ['timestamp']}),
    ]
    inlines = [RecommendationTagInline]
    list_display = ('thing', 'user', 'comments', 'timestamp')
admin.site.register(Recommendation, RecommendationAdmin)


class TextThingAdmin(admin.ModelAdmin):
    fieldsets = [
        (None, {'fields': ['thing']}),
        (None, {'fields': ['description']}),
    ]
    list_display = ('thing', 'description')
    def has_add_permission(self, request):
        return False
admin.site.register(TextThing, TextThingAdmin)


class TextThingInline(admin.TabularInline):
    model = TextThing
    extra = 1


class ThingAdmin(admin.ModelAdmin):
    fieldsets = [
        (None, {'fields': ['thingType']}),
    ]
    inlines = [TextThingInline]
admin.site.register(Thing, ThingAdmin)

