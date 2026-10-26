package com.novalearn.infrastructure.security;
import com.novalearn.application.auth.TokenService; import com.novalearn.domain.auth.Role; import io.jsonwebtoken.*; import io.jsonwebtoken.security.Keys; import org.springframework.beans.factory.annotation.Value; import org.springframework.stereotype.Component; import javax.crypto.SecretKey; import java.time.Instant; import java.util.*;
@Component public class JwtTokenService implements TokenService {
 private final SecretKey key; private final long ttlSeconds; public JwtTokenService(@Value("${novalearn.security.jwt-secret}") String secret,@Value("${novalearn.security.access-token-ttl-seconds:3600}") long ttlSeconds){this.key=Keys.hmacShaKeyFor(Base64.getDecoder().decode(secret));this.ttlSeconds=ttlSeconds;}
 public String issue(UUID subject,Role role){Instant now=Instant.now();return Jwts.builder().subject(subject.toString()).claim("role",role.name()).issuedAt(Date.from(now)).expiration(Date.from(now.plusSeconds(ttlSeconds))).signWith(key).compact();}
 public Jws<Claims> parse(String token){return Jwts.parser().verifyWith(key).build().parseSignedClaims(token);}
}
