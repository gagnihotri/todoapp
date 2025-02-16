import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing'; // Import this
import { ActivatedRoute } from '@angular/router';
import { WelcomeDataService } from './welcome-data.service';

describe('WelcomeDataService', () => {
  let service: WelcomeDataService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule], // Add this
      providers: [WelcomeDataService, ActivatedRoute] // Ensure service is provided
    });
      service = TestBed.inject(WelcomeDataService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
