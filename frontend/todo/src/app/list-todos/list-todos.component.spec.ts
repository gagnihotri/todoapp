import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ListTodosComponent, Todo } from './list-todos.component';
import { TodoDataService } from '../service/data/todo-data.service';
import { Router } from '@angular/router';
import { of, throwError } from 'rxjs';
import { HttpClientTestingModule } from '@angular/common/http/testing';

describe('ListTodosComponent', () => {
  let component: ListTodosComponent;
  let fixture: ComponentFixture<ListTodosComponent>;
  let mockTodoService: jasmine.SpyObj<TodoDataService>;
  let mockRouter: jasmine.SpyObj<Router>;

  beforeEach(async () => {
    mockTodoService = jasmine.createSpyObj('TodoDataService', ['retrieveAllTodos', 'deleteTodo']);
    mockRouter = jasmine.createSpyObj('Router', ['navigate']);

    await TestBed.configureTestingModule({
      imports: [HttpClientTestingModule], // ✅ Import HttpClientTestingModule
      declarations: [ListTodosComponent],
      providers: [
        { provide: TodoDataService, useValue: mockTodoService },
        { provide: Router, useValue: mockRouter }
      ]
    }).compileComponents();
  });

  beforeEach(() => {
    mockTodoService.retrieveAllTodos.and.returnValue(of([]));

    fixture = TestBed.createComponent(ListTodosComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create the component', () => {
    expect(component).toBeTruthy();
  });

  it('should retrieve all todos on initialization', () => {
    const mockTodos: Todo[] = [
      new Todo(1, 'Victor', 'Learn Dance', false, new Date()),
      new Todo(2, 'Victor', 'Finish Work', true, new Date()),
    ];
    mockTodoService.retrieveAllTodos.and.returnValue(of(mockTodos));

    component.refreshTodos();

    expect(mockTodoService.retrieveAllTodos).toHaveBeenCalledWith('Victor');
    expect(component.todos).toEqual(mockTodos);
    expect(component.todos[0].description).toBe('Learn Dance');
  });

  it('should delete a todo and refresh the list', () => {
    mockTodoService.deleteTodo.and.returnValue(of({}));
    spyOn(component, 'refreshTodos'); // ✅ Spy on refreshTodos method

    component.deleteToDo(1, 'Learn Dance');

    expect(mockTodoService.deleteTodo).toHaveBeenCalledWith('Victor', 1);
    expect(component.message).toBe('Todo ID: 1 - Learn Dance Deleted Successfully');
    expect(component.refreshTodos).toHaveBeenCalled(); // ✅ Check if refreshTodos was called
  });

  it('should handle an error when deleting a todo', () => {
    mockTodoService.deleteTodo.and.returnValue(throwError(() => new Error('Delete failed')));

    component.deleteToDo(1, 'Learn Dance');

    expect(mockTodoService.deleteTodo).toHaveBeenCalledWith('Victor', 1);
    // Error should be logged to console
  });

  it('should navigate to update a todo', () => {
    component.updateToDo(1);
    expect(mockRouter.navigate).toHaveBeenCalledWith(['todos', 1]);
  });

  it('should navigate to add a new todo', () => {
    component.addTodo();
    expect(mockRouter.navigate).toHaveBeenCalledWith(['todos', -1]);
  });
});
