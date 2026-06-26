package com.ren.yinghui.backend.mapper;

import com.ren.yinghui.backend.entity.User;
import com.ren.yinghui.backend.vo.UserInfoVO;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;

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
    @Options(useGeneratedKeys = true, keyProperty = "id")
    void insert(User user);

    //initialize platform trading wallet for new user
    @Insert("""
            insert into user_wallets(user_id, usd_balance, btc_balance)
            values(#{userId}, #{usdBalance}, #{btcBalance})
            """)
    void insertWallet(@Param("userId") Long userId,
                      @Param("usdBalance") BigDecimal usdBalance,
                      @Param("btcBalance") BigDecimal btcBalance);

    //get current user info
    @Select("select id, name, email from users where id=#{id}")
    UserInfoVO findUserInfoById(Long id);
}
