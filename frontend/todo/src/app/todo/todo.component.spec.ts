import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TodoComponent } from './todo.component';
import { FormsModule } from '@angular/forms';  
import { TodoDataService } from '../service/data/todo-data.service';
import { ActivatedRoute, Router } from '@angular/router';
import { of } from 'rxjs';
import { Todo } from '../list-todos/list-todos.component';

describe('TodoComponent', () => {
  let component: TodoComponent;
  let fixture: ComponentFixture<TodoComponent>;
  let todoServiceMock: jasmine.SpyObj<TodoDataService>;

  beforeEach(async () => {
    // ✅ Create a mock service with spies
    todoServiceMock = jasmine.createSpyObj('TodoDataService', [
      'retrieveTodo',
      'createTodo',
      'updateTodo'
    ]);

    const activatedRouteMock = {
      snapshot: {
        params: {
          id: 1  // ✅ Simulate paramMap.get('id')
        }
      }
    };

    const routerMock = jasmine.createSpyObj('Router', ['navigate']);

    await TestBed.configureTestingModule({
      declarations: [TodoComponent],
      imports: [FormsModule],
      providers: [
        { provide: TodoDataService, useValue: todoServiceMock },
        { provide: ActivatedRoute, useValue: activatedRouteMock },
        { provide: Router, useValue: routerMock },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(TodoComponent);
    component = fixture.componentInstance;
  });

  it('should retrieve todo when ID is not -1', () => {
    const mockTodo: Todo = new Todo(1, 'Victor', 'Test Todo', false, new Date());

    // ✅ Mock retrieveTodo to return an observable
    todoServiceMock.retrieveTodo.and.returnValue(of(mockTodo));

    fixture.detectChanges(); // ✅ Triggers ngOnInit()

    expect(todoServiceMock.retrieveTodo).toHaveBeenCalledWith('Victor', 1);
    expect(component.todo).toEqual(mockTodo);
  });
});
