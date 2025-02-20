import { Component, OnInit } from '@angular/core';
import { TodoDataService } from '../service/data/todo-data.service';
import { Router } from '@angular/router';

export class Todo {

  constructor(
    public id: number,
    public username: string,
    public description: string,
    public done: boolean,
    public targetDate: Date,
    ) { }
}

@Component({
  selector: 'app-list-todos',
  templateUrl: './list-todos.component.html',
  styleUrls: ['./list-todos.component.css']
})

export class ListTodosComponent implements OnInit {

  todos: Todo[] = []
  message:string=""

  constructor(
    private todoService:TodoDataService,
    private router:Router,
  ) { }

  ngOnInit(): void {
    this.refreshTodos();
  }

  refreshTodos(){
    this.todoService.retrieveAllTodos('Victor').subscribe(
      response => {
        console.log(response)
        this.todos = response
        // Sort todos so that 'true' values come after 'false' values
        this.todos.sort((a, b) => a.done === b.done ? 0 : a.done ? 1 : -1);
      }
    )
  }

  deleteToDo(id: number, description: string): void {
    console.log(`to do delete ${id}`);
    this.todoService.deleteTodo('Victor', id).subscribe(
      response => {
        console.log(response); // e.g. delete todo 1
        this.message = `Todo ID: ${id} - ${description} Deleted Successfully`;
        this.refreshTodos();
      },
      error => {
        console.error(error);
        // Handle error if deletion fails
      }
    );
  }

  updateToDo(id: number): void {
    console.log(`to do delete ${id}`);
    this.router.navigate(['todos', id]);
  }

  addTodo(){
    this.router.navigate(['todos', -1])
  }

}
