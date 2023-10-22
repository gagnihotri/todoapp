//
//package com.springboot.rest.webservices.restfulwebservices.basic.auth;
//
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.http.HttpMethod;
//import org.springframework.security.config.Customizer;
//import org.springframework.security.config.annotation.web.builders.HttpSecurity;
//import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
//import org.springframework.security.config.http.SessionCreationPolicy;
//import org.springframework.security.web.SecurityFilterChain;
//import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
//import org.springframework.security.web.util.matcher.RequestMatcher;
//import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
//@Deprecated
//@Configuration
//@EnableWebSecurity
//public class SpringSecurityConfigurationBasicAuth{
//    @Bean
//    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
//        RequestMatcher optionsMatcher = new AntPathRequestMatcher("/**", HttpMethod.GET.toString());
//        //1: Response to preflight request doesn't pass access control check
//        //2: basic auth
//        return
//                http
//                    .authorizeHttpRequests(
//                        auth ->
//                            auth
//                            .requestMatchers(optionsMatcher).permitAll()
//                            .requestMatchers(new AntPathRequestMatcher("/**")).authenticated())
//                    .httpBasic(Customizer.withDefaults())
//                    .sessionManagement(
//                        session -> session.sessionCreationPolicy
//                        (SessionCreationPolicy.STATELESS))
//                    .csrf().disable()
//                    .build();
//    }
//}