from rest_framework.routers import DefaultRouter
from friends_best.views import *


router = DefaultRouter()
router.register(r'user', UserViewSet)
router.register(r'query', QueryViewSet, base_name='api')
router.register(r'recommend', RecommendationViewSet)
router.register(r'recommendationtag', RecommendationTagViewSet)
