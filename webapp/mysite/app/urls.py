from django.urls import path

from . import views

urlpatterns = [
    path("", views.index, name="index"),
    path("getDetails/", views.getDetils, name="getDetails"),
]
