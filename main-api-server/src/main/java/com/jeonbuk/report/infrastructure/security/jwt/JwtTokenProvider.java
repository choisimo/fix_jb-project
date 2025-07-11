package com.jeonbuk.report.infrastructure.security.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import com.jeonbuk.report.infrastructure.security.CustomUserDetailsService;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import javax.crypto.SecretKey;
import java.util.Base64;
import java.util.Date;

@Component
public class JwtTokenProvider {

    @Value("${app.jwt.secret:defaultSecretKey}")
    private String secretKey;

    @Value("${app.jwt.expiration:3600000}")
    private long tokenValidityInSeconds;

    @Value("${app.jwt.refresh-expiration:604800000}")
    private long refreshTokenValidityInSeconds;

    private SecretKey key;

    private final CustomUserDetailsService userDetailsService;

    public JwtTokenProvider(CustomUserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    @PostConstruct
    protected void init() {
        String encodedKey = Base64.getEncoder().encodeToString(secretKey.getBytes());
        this.key = Keys.hmacShaKeyFor(encodedKey.getBytes());
    }

    public String createToken(String username) {
        Date now = new Date();
        Date validity = new Date(now.getTime() + tokenValidityInSeconds);
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(now)
                .setExpiration(validity)
                .claim("type", "access")
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public String createRefreshToken(String username) {
        Date now = new Date();
        Date validity = new Date(now.getTime() + refreshTokenValidityInSeconds);
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(now)
                .setExpiration(validity)
                .claim("type", "refresh")
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public String createTempToken(String username) {
        Date now = new Date();
        Date validity = new Date(now.getTime() + 300 * 1000); // 5분 유효
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(now)
                .setExpiration(validity)
                .claim("type", "temp")
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public long getTokenValidityInMilliseconds() {
        return tokenValidityInSeconds;
    }

    public Authentication getAuthentication(String token) {
        String username = getUsername(token);
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);
        return new UsernamePasswordAuthenticationToken(userDetails, "", userDetails.getAuthorities());
    }

    public String getUsername(String token) {
        return Jwts.parser().setSigningKey(key).build()
                .parseClaimsJws(token).getBody().getSubject();
    }

    public boolean validateToken(String token) {
        try {
            Claims claims = Jwts.parser().setSigningKey(key).build().parseClaimsJws(token).getBody();
            return !claims.getExpiration().before(new Date());
        } catch (Exception e) {
            return false;
        }
    }

    public String getTokenType(String token) {
        try {
            Claims claims = Jwts.parser().setSigningKey(key).build().parseClaimsJws(token).getBody();
            return (String) claims.get("type");
        } catch (Exception e) {
            return null;
        }
    }

    public boolean isRefreshToken(String token) {
        return "refresh".equals(getTokenType(token));
    }

    public boolean isTempToken(String token) {
        return "temp".equals(getTokenType(token));
    }
}
