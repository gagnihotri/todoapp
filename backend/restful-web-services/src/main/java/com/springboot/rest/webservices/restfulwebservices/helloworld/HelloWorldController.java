package com.springboot.rest.webservices.restfulwebservices.helloworld;

import javax.management.RuntimeErrorException;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

// Controller
@CrossOrigin(origins = "http://localhost:4200")
@RestController
public class HelloWorldController {


    // GET
    // URI - /hello-world
    // method - return "Hello World"
    @GetMapping(path="/hello-world")
    public String helloWorld(){
        return "Hello World";
    }

    // return a bean
    // URI - hello-world-bean
    // return message will be in Json
    @GetMapping(path="/hello-world-bean")
    public HelloWorldBean helloWorldBean(){
        // throw new RuntimeErrorException(null, "Some Error has Happened");
        return new HelloWorldBean("Welcome to ToDos, I hope you enjoy the app!");
    }

    // http://localhost:8080/hello-world/path-variable/myname
    @GetMapping(path="/hello-world/path-variable/{name}")
    public HelloWorldBean helloWorldPathVariable(@PathVariable String name){
        return new HelloWorldBean(String.format("You're So Cool, %s", name));
    }
    
}
