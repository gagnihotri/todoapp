import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing'; // Import this
import { HardcodedAuthenticationService } from './hardcoded-authentication.service';

describe('HardcodedAuthenticationService', () => {
  let service: HardcodedAuthenticationService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule], // Add this
      providers: [HardcodedAuthenticationService] // Ensure service is provided
    });
    service = TestBed.inject(HardcodedAuthenticationService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
