package com.ren.yinghui.backend.service.impl;

import com.ren.yinghui.backend.mapper.UserMapper;
import com.ren.yinghui.backend.entity.User;
import com.ren.yinghui.backend.service.UserService;
import com.ren.yinghui.backend.utils.PasswordUtils;
import com.ren.yinghui.backend.utils.ThreadLocalUtil;
import com.ren.yinghui.backend.vo.UserInfoVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class UserServiceImpl implements UserService {
    //constructor injection
    private final UserMapper userMapper;
    @Autowired
    public UserServiceImpl(UserMapper userMapper) {
        this.userMapper = userMapper;
    }
    //get user by name
    @Override
    public User findByName(String name) {
        User user = userMapper.findByName(name);
        return user;
    }

    @Override
    public User findByEmail(String email) {
        return userMapper.findByEmail(email);
    }

    @Override
    public void register(String name, String email, String password) {
        String passwordHash = PasswordUtils.encode(password);
        userMapper.insert(name, email, passwordHash);
    }

    @Override
    public boolean checkPassword(String password, String passwordHash) {
        return PasswordUtils.matches(password, passwordHash);
    }

    @Override
    public UserInfoVO findCurrentUser() {
        Map<String, Object> claims = ThreadLocalUtil.get();
        Object userId = claims.get("id");
        Long id = userId instanceof Number number ? number.longValue() : Long.valueOf(userId.toString());
        return userMapper.findUserInfoById(id);
    }
}
