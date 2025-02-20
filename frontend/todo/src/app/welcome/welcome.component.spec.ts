import { ComponentFixture, TestBed } from '@angular/core/testing';
import { WelcomeComponent } from './welcome.component';
import { ActivatedRoute } from '@angular/router';
import { WelcomeDataService } from '../service/data/welcome-data.service';
import { of, throwError } from 'rxjs';
import { HttpClientTestingModule } from '@angular/common/http/testing';

describe('WelcomeComponent', () => {
  let component: WelcomeComponent;
  let fixture: ComponentFixture<WelcomeComponent>;
  let mockWelcomeDataService: jasmine.SpyObj<WelcomeDataService>;

  beforeEach(async () => {
    mockWelcomeDataService = jasmine.createSpyObj('WelcomeDataService', [
      'executeHelloWorldBeanService',
      'executeHelloWorldServiceWithPathVariable'
    ]);

    await TestBed.configureTestingModule({
      imports: [HttpClientTestingModule], //
      declarations: [WelcomeComponent],
      providers: [
        { provide: ActivatedRoute, useValue: { snapshot: { params: { name: 'Victor' } } } },
        { provide: WelcomeDataService, useValue: mockWelcomeDataService }
      ]
    }).compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(WelcomeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create the component', () => {
    expect(component).toBeTruthy();
  });

  it('should initialize with the correct name from route parameters', () => {
    expect(component.name).toBe('Victor');
  });

  it('should call WelcomeDataService and get a successful response', () => {
    const mockResponse = { message: 'Hello World' };
    mockWelcomeDataService.executeHelloWorldBeanService.and.returnValue(of(mockResponse));

    component.getWelcomeMessage();

    expect(mockWelcomeDataService.executeHelloWorldBeanService).toHaveBeenCalled();
    expect(component.welcomeMessageFromService).toBe('Hello World');
  });

  it('should call WelcomeDataService and handle an error response', () => {
    const mockError = { error: { message: 'An error occurred' } };
    mockWelcomeDataService.executeHelloWorldBeanService.and.returnValue(throwError(() => mockError));

    component.getWelcomeMessage();

    expect(mockWelcomeDataService.executeHelloWorldBeanService).toHaveBeenCalled();
    // Error should be logged to console
  });

  it('should call WelcomeDataService with parameter and get a successful response', () => {
    const mockResponse = { message: 'Hello, Victor' };
    mockWelcomeDataService.executeHelloWorldServiceWithPathVariable.and.returnValue(of(mockResponse));

    component.getWelcomeMessageWithParameter();

    expect(mockWelcomeDataService.executeHelloWorldServiceWithPathVariable).toHaveBeenCalledWith('Victor');
    expect(component.welcomeMessageWithParameterFromService).toBe('Hello, Victor');
  });

  it('should call WelcomeDataService with parameter and handle an error response', () => {
    const mockError = { error: { message: 'An error occurred' } };
    mockWelcomeDataService.executeHelloWorldServiceWithPathVariable.and.returnValue(throwError(() => mockError));

    component.getWelcomeMessageWithParameter();

    expect(mockWelcomeDataService.executeHelloWorldServiceWithPathVariable).toHaveBeenCalledWith('Victor');
    expect(component.welcomeMessageWithParameterFromService).toBe('Error Occured: An error occurred');
  });
});
