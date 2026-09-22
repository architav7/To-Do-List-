from django.urls import path
from .views import todo, add_task, delete_task, toggletodo

urlpatterns = [
    path('' , todo, name = "homepage"),
    path('add/', add_task, name = "addtask"),
    path('delete/<int:task_id>', delete_task),
    path('toggletodo/<int:task_id>', toggletodo)
]

