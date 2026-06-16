package com.ren.yinghui.backend.vo;


import lombok.Data;

//统一响应结果
//Unified response result
@Data
public class Result<T> {
    private Integer code;// Business status code  0-Success  1-Failure
    private String message;// Message
    private T data;// Response data

    public Result() {
    }

    public Result(Integer code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
    }

    //快速返回操作成功响应结果(带响应数据)
    // Quick return for successful operation (with response data)
    public static <E> Result<E> success(E data) {
        return new Result<>(0, "Operation successful", data);
    }

    //快速返回操作成功响应结果
    // Quick return for successful operation (without response data)
    public static Result<Void> success() {
        return new Result<>(0, "Operation successful", null);
    }

    public static <E> Result<E> error(String message) {
        return new Result<>(1, message, null);
    }
}
