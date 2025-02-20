import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { RouteGuardService } from './route-guard.service';

describe('RouteGuardService', () => {
  let service: RouteGuardService;

  beforeEach(() => {
    TestBed.configureTestingModule({
        imports: [HttpClientTestingModule], // Add this
        providers: [RouteGuardService] // Ensure service is provided
      });
      service = TestBed.inject(RouteGuardService);
    });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
