package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.utils.JwtUtil;
import com.ren.yinghui.backend.vo.Result;
import com.ren.yinghui.backend.entity.User;
import com.ren.yinghui.backend.service.UserService;
import com.ren.yinghui.backend.vo.UserInfoVO;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
@Validated
public class UserController {
    //constructor injection
    private final UserService userService;
    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public Result register(@RequestParam @Pattern(regexp = "^\\S{3,16}$") String name,
                           @RequestParam @Email String email,
                           @RequestParam @Pattern(regexp = "^\\S{5,16}$") String password) {
        //get user by name
        User user = userService.findByName(name);
        if (user != null) {
            return Result.error("username already exists");
        }

        //get user by email
        user = userService.findByEmail(email);
        if (user != null) {
            return Result.error("email already exists");
        }

        //register
        userService.register(name, email, password);
        return Result.success();

    }

    @PostMapping("/login")
    public Result login(@RequestParam @Pattern(regexp = "^\\S{3,16}$") String name,
                        @RequestParam @Pattern(regexp = "^\\S{5,16}$") String password) {
        User user = userService.findByName(name);
        //if user doesn't exist
        if(user == null){
            return Result.error("用户不存在");
        }else{
            //user exists
            //if encrypted password matches
            if(userService.checkPassword(password, user.getPasswordHash())){
                //password correct
                //generate token
                Map<String, Object> claims = new HashMap<>();
                claims.put("id", user.getId());
                claims.put("name", user.getName());
                String token = JwtUtil.genToken(claims);
                return Result.success(token);
            }else{
                //password incorrect
                return Result.error("密码不正确");
            }

        }
    }

    @GetMapping("/me")
    public Result<UserInfoVO> me() {
        UserInfoVO user = userService.findCurrentUser();
        if (user == null) {
            return Result.error("user not found");
        }
        return Result.success(user);
    }



}
