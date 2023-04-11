package com.work.exception;

//必须是运行时异常，因为运行时异常支持事务，非运行时异常不支持事务
public class LoginRuntimeException extends RuntimeException {

    public LoginRuntimeException(String message) {
        super(message);
    }
}
