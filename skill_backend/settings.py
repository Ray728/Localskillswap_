# settings.py

ALLOWED_HOSTS = ['*']  # Разрешаем доступ с эмулятора

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',  # <-- Эта строка должна быть только один раз!
    'rest_framework',
    'skills',
]