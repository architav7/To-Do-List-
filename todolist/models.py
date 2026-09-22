from django.db import models
from .models import models

# Create your models here.
class ToDoList(models.Model):
    task = models.CharField(max_length=100)
    is_completed = models.BooleanField(default=False)


     


