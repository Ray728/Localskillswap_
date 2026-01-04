from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse # <--- Добавь импорт

# <--- Добавь простую функцию для главной страницы
def home_view(request):
    return HttpResponse("Сервер работает! Иди на /api/skills/")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('skills.urls')),
    path('', home_view), # <--- Добавтть этот путь (пустая строка означает корень)
]