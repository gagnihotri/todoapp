import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { WelcomeComponent } from './welcome/welcome.component';
import { ErrorComponent } from './error/error.component';
import { ListTodosComponent } from './list-todos/list-todos.component';
import { LogoutComponent } from './logout/logout.component';
import { RouteGuardService } from './service/route-guard.service';
import { TodoComponent } from './todo/todo.component';

// welcome
const routes: Routes = [
  // http://localhost:4200/ -> http://localhost:4200/login -> LoginComponent
  {path:'', component: LoginComponent}, //canActivate based on session, RouteGuardService

  // http://localhost:4200/login -> LoginComponent
  {path:'login', component: LoginComponent}, 

  // http://localhost:4200/welcome -> WelcomeComponent
  // insert name routing parameter
  {path:'welcome/:name', component: WelcomeComponent, canActivate:[RouteGuardService]}, 

  // http://localhost:4200/todos -> ListTodosComponent
  {path:'todos', component: ListTodosComponent, canActivate:[RouteGuardService]}, 

  // http://localhost:4200/logout -> LogoutComponent
  {path:'logout', component: LogoutComponent, canActivate:[RouteGuardService]},  

   // http://localhost:4200/todos/1 -> TodoComponent
  {path:'todos/:id', component: TodoComponent, canActivate:[RouteGuardService]}, 

  // http://localhost:4200/error -> ErrorComponent
  {path:'**', component: ErrorComponent},
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
