package com.ren.yinghui.backend.mapper;

import com.ren.yinghui.backend.entity.User;
import com.ren.yinghui.backend.vo.UserInfoVO;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserMapper {
    //get user by name
    @Select("select * from users where name=#{name}")
    User findByName(String name);

    //get user by email
    @Select("select * from users where email=#{email}")
    User findByEmail(String email);

    //register user
    @Insert("insert into users(name, email, password_hash) values(#{name}, #{email}, #{passwordHash})")
    void insert(@Param("name") String name, @Param("email") String email, @Param("passwordHash") String passwordHash);

    //get current user info
    @Select("select id, name, email from users where id=#{id}")
    UserInfoVO findUserInfoById(Long id);
}
