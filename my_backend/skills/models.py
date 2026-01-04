from django.db import models

class Skill(models.Model):
    title = models.CharField(max_length=100)       # Что ищу (Например: Уроки пианино)
    offer = models.CharField(max_length=100, default="") # НОВОЕ: Что даю взамен (Например: Английский)
    description = models.TextField()               # Описание
    location = models.CharField(max_length=100)    # Город
    owner_name = models.CharField(max_length=100)  # Имя автора
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title