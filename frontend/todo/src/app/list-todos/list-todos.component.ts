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
  // = [
  //   new Todo(1, "Learn  Dance", false, new Date()),
  //   new Todo(2, "Finish Work", true, new Date()),
  //   new Todo(3, "Play Basketball", false, new Date()),
  //   new Todo(4, "Learn Soccer", false, new Date()),

  //   // {id : 1, description: "Learn  Dance"},
  //   // {id : 2, description: "Finish Work"},
  //   // {id : 3, description: "Play Basketball"},
  //   // {id : 4, description: "Learn Soccer"},
  // ]

  // todo = {
  //   id : 1,
  //   description: "Learn to Dance"
  // }

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
