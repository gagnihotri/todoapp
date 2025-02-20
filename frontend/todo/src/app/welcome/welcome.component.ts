import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { WelcomeDataService } from '../service/data/welcome-data.service';

@Component({
  selector: 'app-welcome',
  templateUrl: './welcome.component.html',
  styleUrls: ['./welcome.component.css']
})
export class WelcomeComponent implements OnInit {

  message = "Welcome To Website"
  name = ''
  welcomeMessageFromService : string = ""
  welcomeMessageWithParameterFromService : string = ""

  // ActivatedRoute 
  // provides access to the route parameters, query parameters, 
  // and other data associated with the activated route
  constructor(private route:ActivatedRoute,
    private welcomeDataService: WelcomeDataService) { }

  ngOnInit(): void { // this method will run when this component is initialized
    console.log(this.message)
    this.name = this.route.snapshot.params['name']
    
  }

  getWelcomeMessage(){
    console.log(this.welcomeDataService.executeHelloWorldBeanService());
    this.welcomeDataService.executeHelloWorldBeanService().subscribe(
      response => this.handleSuccessfulResponse(response),
      error => this.handleErrorResponse(error),
    );
    // onsole.log("Get Welcome Message button pressed")
  }

  getWelcomeMessageWithParameter(){
    console.log(this.welcomeDataService.executeHelloWorldServiceWithPathVariable(this.name));
    this.welcomeDataService.executeHelloWorldServiceWithPathVariable(this.name).subscribe(
      response => this.handleSuccessfulWithParameterResponse(response),
      error => this.handleErrorWithParameterResponse(error),
    );
    // onsole.log("Get Welcome Message button pressed")
  }

  handleSuccessfulResponse(response:any){
    this.welcomeMessageFromService = response.message;
  }

  handleErrorResponse(error: any) {
    console.error(error); // Log the error for debugging purposes
  }

  handleSuccessfulWithParameterResponse(response:any){
    this.welcomeMessageWithParameterFromService = response.message;
  }

  handleErrorWithParameterResponse(error: any) {
    console.error(error); // Log the error for debugging purposes
    this.welcomeMessageWithParameterFromService = `Error Occured: ${error.error.message}`;
  }

}
