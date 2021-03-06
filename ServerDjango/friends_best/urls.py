from rest_framework.routers import DefaultRouter
from friends_best.views import *


from django.conf.urls import include, url
urlpatterns = [
    url(r'', include('gcm.urls')),
]

router = DefaultRouter()
router.register(r'query', QueryViewSet, base_name='api')
router.register(r'recommend', RecommendationViewSet)
router.register(r'pin', PinViewSet)
router.register(r'notification', NotificationViewSet)
router.register(r'prompt', PromptViewSet)
router.register(r'accolade', AccoladeViewSet)
router.register(r'friend', FriendshipViewSet)
router.register(r'me', CurrentUserViewSet)

# Tag cloud
router.register(r'recommendationtag', RecommendationTagViewSet)


