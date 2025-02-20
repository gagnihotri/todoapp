import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { HardcodedAuthenticationService } from '../service/hardcoded-authentication.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {

  username = "Victor"
  password = "password1"
  errorMessage = "Invalid Credentials"
  invalidLogin = false

  // In order to redirect to the welcome page, 
  // you need a instance of the router
  // Router
  // older version: Angular.giveMeRouter
  // newer version: Dependency Injection

  // Using depency injection to inject router
  constructor(private router: Router,
    private hardcodeAuthenticationService: HardcodedAuthenticationService) { }

  ngOnInit(): void {
  }

  handleLogin() {
    console.log(this.username);
    console.log(this.password);

    // Authentication
    //if (this.username === "username" && this.password === "password"){

    if (this.hardcodeAuthenticationService.authenticate(this.username, this.password)){

      // Redirect to Welcome Page
      this.router.navigate(['welcome', this.username]);

      this.invalidLogin = false
    } else {
      this.invalidLogin = true
    }
  }

}
