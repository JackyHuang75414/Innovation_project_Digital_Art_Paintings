package com.ren.yinghui.backend.config;

import com.ren.yinghui.backend.vo.Result;
import jakarta.validation.ConstraintViolationException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ConstraintViolationException.class)
    public Result handleValidation(ConstraintViolationException e) {
        String msg = e.getConstraintViolations().stream()
                .map(v -> v.getMessage())
                .findFirst()
                .orElse("Invalid input");
        return Result.error(msg);
    }

    @ExceptionHandler(Exception.class)
    public Result handleGeneral(Exception e) {
        return Result.error(e.getMessage() != null ? e.getMessage() : "Internal server error");
    }
}
