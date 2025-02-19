package com.springboot.rest.webservices.restfulwebservices.todo;

import java.net.URI;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import org.springframework.http.HttpStatus;

@CrossOrigin(origins = "http://frontend-app")
@RestController
public class TodoResource {

    @Autowired
    private ToDoHardcodedService todoService;

    // Get all todos for a specific user
    // http://localhost:8080/users/Victor/todos
    @GetMapping("/users/{username}/todos")
    public List<Todo> getAllTodos(@PathVariable String username){
        return todoService.findAll();
    }

    // http://localhost:8080/users/Victor/todos/1
    @GetMapping("/users/{username}/todos/{id}")
    public Todo getTodo(@PathVariable String username, @PathVariable long id){
        return todoService.findById(id);
    }

    // Delete /users/{username}/todos/{id}
    // return a custom response
    @DeleteMapping("/users/{username}/todos/{id}")
    public ResponseEntity<Void> deleteTodo(@PathVariable String username, @PathVariable long id) {
        Todo todo = todoService.deleteById(id);
        if (todo != null) {
            // return a status of no content if succesfully deleted
            return ResponseEntity.noContent().build();
        }

        // return notFound status
        return ResponseEntity.notFound().build();
    }

    // Edit a Todo
    //PUT /users/{username}/todos/{id}
    @PutMapping("/users/{username}/todos/{id}")
    public ResponseEntity<Todo> updateTodo(@PathVariable String username, @PathVariable long id, @RequestBody Todo todo) {
        Todo todoUpdate = todoService.save(todo);
        return new ResponseEntity<Todo>(todo, HttpStatus.OK);
    }

    // Create a Todo
    @PostMapping("/users/{username}/todos")
    public ResponseEntity<Void> createTodo(@PathVariable String username, @RequestBody Todo todo) {
        Todo createdTodo = todoService.create(todo);

        if (createdTodo != null) {
            // Build the URI for the created Todo
            URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                    .path("/{id}")
                    .buildAndExpand(createdTodo.getId())
                    .toUri();

            // Return a response with the URI of the created Todo
            return ResponseEntity.created(uri).build();
        } else {
            // Return a bad request status if the todo creation fails
            return ResponseEntity.badRequest().build();
        }
    }
}

