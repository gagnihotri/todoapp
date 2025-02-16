import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { WelcomeDataService, HelloWorldBean } from './welcome-data.service';

describe('WelcomeDataService', () => {
  let service: WelcomeDataService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule], // ✅ Import HttpClientTestingModule
      providers: [WelcomeDataService],
    });

    service = TestBed.inject(WelcomeDataService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify(); // ✅ Ensures that no unmatched requests remain
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('should retrieve HelloWorldBean from executeHelloWorldBeanService', () => {
    const mockResponse: HelloWorldBean = { message: 'Hello World' };

    service.executeHelloWorldBeanService().subscribe(response => {
      expect(response).toEqual(mockResponse);
    });

    // ✅ Mock the HTTP GET request
    const req = httpMock.expectOne('http://localhost:8080/hello-world-bean');
    expect(req.request.method).toBe('GET');
    req.flush(mockResponse); // ✅ Simulate response
  });

  it('should retrieve HelloWorldBean from executeHelloWorldServiceWithPathVariable', () => {
    const name = 'Victor';
    const mockResponse: HelloWorldBean = { message: `Hello, ${name}` };

    service.executeHelloWorldServiceWithPathVariable(name).subscribe(response => {
      expect(response).toEqual(mockResponse);
    });

    // ✅ Mock the HTTP GET request
    const req = httpMock.expectOne(`http://localhost:8080/hello-world/path-variable/${name}`);
    expect(req.request.method).toBe('GET');
    req.flush(mockResponse); // ✅ Simulate response
  });
});
