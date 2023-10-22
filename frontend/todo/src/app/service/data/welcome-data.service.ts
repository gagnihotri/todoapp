import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';

export class HelloWorldBean{
  constructor(public message: string){}
}

@Injectable({
  providedIn: 'root'
})
export class WelcomeDataService {

  constructor(
    private httpClient:HttpClient,
  ) { }

  // retrieving data from backend through url in json format
  executeHelloWorldBeanService(){
    return this.httpClient.get<HelloWorldBean>('http://localhost:8080/hello-world-bean');
    // console.log("Execute Hello World Bean Service")
  }

  // retrieving data from backend through url *wiht parameter* in json format
  executeHelloWorldServiceWithPathVariable(name: string){
    let basicAuthHeaderString = this.createBasicAuthenticationHttpHeader();
    let headers = new HttpHeaders(
      {
        Authorization: basicAuthHeaderString
      }
    )
    return this.httpClient.get<HelloWorldBean>(`http://localhost:8080/hello-world/path-variable/${name}`, {headers});
  }


  // allow front end with basic authentication to retrieve data from backend
  createBasicAuthenticationHttpHeader(){
    let username = "user";
    let password = "password1";
    let basicAuthHeaderString = "Basic" + window.btoa(username + ":" + password);
    return basicAuthHeaderString;
  }
}
