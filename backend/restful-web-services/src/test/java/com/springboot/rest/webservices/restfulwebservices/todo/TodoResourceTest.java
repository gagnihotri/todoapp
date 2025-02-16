package com.springboot.rest.webservices.restfulwebservices.todo;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import org.springframework.boot.test.mock.mockito.MockBean;
import com.springboot.rest.webservices.restfulwebservices.RestfulWebServicesApplication;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;

import java.util.Arrays;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.*;   
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@SpringBootTest(classes = RestfulWebServicesApplication.class)
@AutoConfigureMockMvc
public class TodoResourceTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ToDoHardcodedService todoService;

    private Todo todo1;
    private Todo todo2;

    @BeforeEach
    public void setup() {
        todo1 = new Todo(1L, "Victor", "Learn Spring Boot", null, false);
        todo2 = new Todo(2L, "Victor", "Complete Unit Tests", null, false);
    }

    // Test the GET all todos endpoint
    @Test
    public void testGetAllTodos() throws Exception {
        when(todoService.findAll()).thenReturn(Arrays.asList(todo1, todo2));

        mockMvc.perform(get("/users/Victor/todos"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[1].id").value(2))
                .andExpect(jsonPath("$[0].username").value("Victor"))
                .andExpect(jsonPath("$[1].username").value("Victor"));
    }

    // Test the GET single todo endpoint
    @Test
    public void testGetTodo() throws Exception {
        when(todoService.findById(1L)).thenReturn(todo1);

        mockMvc.perform(get("/users/Victor/todos/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.username").value("Victor"))
                .andExpect(jsonPath("$.description").value("Learn Spring Boot"));
    }

    // Test the DELETE todo endpoint
    @Test
    public void testDeleteTodo() throws Exception {
        when(todoService.deleteById(1L)).thenReturn(todo1);

        mockMvc.perform(delete("/users/Victor/todos/1"))
                .andExpect(status().isNoContent());
    }

    // Test the DELETE todo with not found scenario
    @Test
    public void testDeleteTodo_NotFound() throws Exception {
        when(todoService.deleteById(1L)).thenReturn(null);

        mockMvc.perform(delete("/users/Victor/todos/1"))
                .andExpect(status().isNotFound());
    }

    // Test the PUT (update) todo endpoint
    @Test
    public void testUpdateTodo() throws Exception {
        Todo updatedTodo = new Todo(1L, "Victor", "Learn Spring Boot and Unit Tests", null, true);
        when(todoService.save(any(Todo.class))).thenReturn(updatedTodo);

        mockMvc.perform(put("/users/Victor/todos/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"id\":1,\"username\":\"Victor\",\"description\":\"Learn Spring Boot and Unit Tests\",\"targetDate\":null,\"isDone\":true}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.description").value("Learn Spring Boot and Unit Tests"));
    }

    // Test the POST (create) todo endpoint
    @Test
    public void testCreateTodo() throws Exception {
        when(todoService.create(any(Todo.class))).thenReturn(todo1);

        mockMvc.perform(post("/users/Victor/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"id\":1,\"username\":\"Victor\",\"description\":\"Learn Spring Boot\",\"targetDate\":null,\"isDone\":false}"))
                .andExpect(status().isCreated())
                .andExpect(header().string("Location", "http://localhost/users/Victor/todos/1"));
    }

    // Test the POST (create) todo with bad request scenario
    @Test
    public void testCreateTodo_BadRequest() throws Exception {
        when(todoService.create(any(Todo.class))).thenReturn(null);

        mockMvc.perform(post("/users/Victor/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"id\":1,\"username\":\"Victor\",\"description\":\"\",\"targetDate\":null,\"isDone\":false}"))
                .andExpect(status().isBadRequest());
    }
}
