"""FriendsBest URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.8/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Add an import:  from blog import urls as blog_urls
    2. Add a URL to urlpatterns:  url(r'^blog/', include(blog_urls))
"""
from django.conf.urls import include, url
from django.contrib import admin
from friends_best.urls import router
from django.views.generic.base import RedirectView
from django.conf import settings
from friends_best.views import FacebookLogin
from friends_best.views import deploy
from friends_best.views import queryLink
from django.views.decorators.csrf import csrf_exempt
from friends_best.views import error, django_error, db, fblogout

if settings.DEBUG:
    urlpatterns = [
        
        # LOCAL
        
        # Redirect / to /app/index.html
        url(r'^$', RedirectView.as_view(url='app/index.html', permanent=False), name='index'),
        
        url(r'^fb/admin/', include(admin.site.urls)),
        url(r'^fb/api/', include(router.urls)),
        url(r'^fb/api/facebook/$', FacebookLogin.as_view(), name='fb_login'),
        url(r'^fb/deploy/$', csrf_exempt(deploy)),
        url(r'^fb/error/', error),
        url(r'^fb/django_error/', django_error),
        url(r'^fb/db/', csrf_exempt(db)),
        url(r'^fb/logout/', fblogout),

        # Facebook Postback
        url(r'^fb/link/(?P<query_id>[0-9]+)/', queryLink)
    ]
else:
    urlpatterns = [
        
        # SERVER
        
        url(r'^admin/', include(admin.site.urls)),
        url(r'^api/', include(router.urls)),
        url(r'^api/facebook/$', FacebookLogin.as_view(), name='fb_login'),
        url(r'^deploy/$', csrf_exempt(deploy)),
        url(r'^error/$', error),
        url(r'^django_error/', django_error),
        url(r'^db/', csrf_exempt(db)),
        # url(r'^logout/', LogoutView.as_view()),
        
        # Facebook Postback
        url(r'^link/(?P<query_id>[0-9]+)/$', queryLink)
    ]
