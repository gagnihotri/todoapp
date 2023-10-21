package com.springboot.rest.webservices.restfulwebservices.todo;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.stereotype.Service;

// this will act as our hardcoded database for now
@Service
public class ToDoHardcodedService {
    private static List<Todo> todos = new ArrayList<Todo>();
    private static long idCounter = 0;

    static {
        todos.add(new Todo(++idCounter, "Victor", "Learn to Dance", new Date(), false));
        todos.add(new Todo(++idCounter, "Victor", "Learn Basketball", new Date(), false));
        todos.add(new Todo(++idCounter, "Victor", "Learn Gaming", new Date(), false));
        todos.add(new Todo(++idCounter, "Victor", "Learn Swimming", new Date(), false));
        todos.add(new Todo(++idCounter, "Victor", "Read a Book", new Date(), false));
        todos.add(new Todo(++idCounter, "Victor", "Write Code", new Date(), false));
        todos.add(new Todo(++idCounter, "Victor", "Cook Dinner", new Date(), false));
    }

    public List<Todo> findAll(){
        return todos;
    }

    public Todo deleteById(long id) {
        Todo todo = findById(id);
        
        // If the Todo item with the given ID is not found, return null.
        if (todo == null) {
            return null;
        }

        // If removal is successful, return the deleted Todo item.
        if(todos.remove(todo)){
            return todo;
        } else {
            // If removal fails, return null to indicate deletion failure.
            return null;
        } 
    }

    public Todo findById(long id) {
        for (Todo todo : todos) {
            if (todo.getId() == id) {
                return todo; // Return the todo if found
            }
        }
        return null; // If todo with given id is not found
    }

    public Todo save(Todo todo) {
        // If the todo has an ID of -1, treat it as a new todo.
        if (todo.getId() == -1) {
            // Generate a new ID and add it to the list.
            todo.setId(++idCounter);
            todos.add(todo);
            return todo;
        } else if (todo.getId() > 0) {
            // If the todo has a positive ID, it means it's an existing todo that needs to be updated.
            Todo existingTodo = findById(todo.getId());
            if (existingTodo != null) {
                // Update the existing todo with the new values
                existingTodo.setDescription(todo.getDescription());
                existingTodo.setTargetDate(todo.getTargetDate());
                existingTodo.setDone(todo.isDone());
                return existingTodo;
            }
        }

        // If the todo ID is not valid (negative other than -1), return null to indicate failure.
        return null;
    }

    public Todo create(Todo todo) {
        // If the todo ID is -1 or not set, treat it as a new todo.
        if (todo.getId() == -1 || todo.getId() == 0) {
            // Generate a new ID and add it to the list.
            todo.setId(++idCounter);
            todos.add(todo);
            return todo;
        }
    
        // If the todo ID is valid and already exists, return null to indicate failure.
        return null;
    }
}
