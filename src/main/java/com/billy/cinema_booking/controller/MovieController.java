package com.billy.cinema_booking.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.billy.cinema_booking.entity.Movie;
import com.billy.cinema_booking.repository.MovieRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/movies")
@RequiredArgsConstructor
public class MovieController {
    private final MovieRepository movieRepository;

    @GetMapping
    public List<Movie> getAllMovies() {
        return movieRepository.findAll();
    }
}
