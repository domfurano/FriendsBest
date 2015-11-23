from rest_framework.routers import DefaultRouter
from friends_best.views import *


router = DefaultRouter()
router.register(r'user', UserViewSet)
router.register(r'friend', FriendViewSet)
router.register(r'query', QueryViewSet)
router.register(r'thing', ThingViewSet)
router.register(r'recommend', RecommendationViewSet)
router.register(r'text', TextViewSet)
