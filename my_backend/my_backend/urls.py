from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    # говорим Django: "Все запросы на /api/ отправляй в приложение skills"
    path('api/', include('skills.urls')),
]