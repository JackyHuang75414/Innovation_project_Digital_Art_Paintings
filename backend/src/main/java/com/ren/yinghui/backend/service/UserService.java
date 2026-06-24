package com.ren.yinghui.backend.service;

import com.ren.yinghui.backend.entity.User;
import com.ren.yinghui.backend.vo.UserInfoVO;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;

public interface UserService {
    //get user by name
    User findByName(@Pattern(regexp = "^\\S{5,16}$") String name);

    //get user by email
    User findByEmail(@Email String email);

    //register
    void register(@Pattern(regexp = "^\\S{5,16}$") String name, @Email String email, @Pattern(regexp = "^\\S{5,16}$") String password);

    //check password
    boolean checkPassword(String password, String passwordHash);

    //get current user info
    UserInfoVO findCurrentUser();
}
