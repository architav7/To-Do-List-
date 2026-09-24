from django.shortcuts import render,redirect
from .models import ToDoList

# Create your views here.
def todo(request):
    tast_retrived = ToDoList.objects.all()
    context = {'tasks' : tast_retrived}
    return render(request, 'index.html' , context)

def add_task(request):
    if request.method == "POST":
        new_task = request.POST.get('task')

        ToDoList.objects.create(
            task = new_task,
            
        )    
    return redirect("homepage")

def delete_task(request, task_id):
    retrieve_task = ToDoList.objects.get(id = task_id)
    retrieve_task.delete()
    return redirect("homepage")
    

def toggletodo(request, task_id):
    retrieve_todo = ToDoList.objects.get(id = task_id)
    retrieve_todo.is_completed = not retrieve_todo.is_completed
    retrieve_todo.save()

    return redirect("homepage")

