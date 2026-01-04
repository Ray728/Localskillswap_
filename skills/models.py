from django.db import models

class Skill(models.Model):
    title = models.CharField(max_length=100)
    description = models.TextField()
    location = models.CharField(max_length=100)
    owner_name = models.CharField(max_length=100)

    def __str__(self):
        return self.title