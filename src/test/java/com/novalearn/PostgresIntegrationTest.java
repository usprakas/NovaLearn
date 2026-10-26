package com.novalearn;
import org.junit.jupiter.api.*; import org.springframework.boot.test.context.SpringBootTest; import org.springframework.jdbc.core.JdbcTemplate; import org.springframework.beans.factory.annotation.Autowired; import org.springframework.test.context.DynamicPropertyRegistry; import org.springframework.test.context.DynamicPropertySource; import org.testcontainers.containers.PostgreSQLContainer; import org.testcontainers.junit.jupiter.*; import static org.assertj.core.api.Assertions.assertThat;
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
@Testcontainers
class PostgresIntegrationTest {
 @Container static final PostgreSQLContainer<?> postgres=new PostgreSQLContainer<>("postgres:16-alpine");
 @DynamicPropertySource static void configure(DynamicPropertyRegistry r){r.add("spring.datasource.url",postgres::getJdbcUrl);r.add("spring.datasource.username",postgres::getUsername);r.add("spring.datasource.password",postgres::getPassword);r.add("novalearn.security.jwt-secret",()->"VGhpcy1pcy1hLWRldi1zZWNyZXQtdGhhdC1pcy1hdC1sZWFzdC0zMi1ieXRlcy1sb25nLXNlY3VyZQ==");}
 @Autowired JdbcTemplate jdbcTemplate;
 @Test void flywayCreatesLearningCoreSchema() { assertThat(jdbcTemplate.queryForObject("select count(*) from parent_accounts", Integer.class)).isZero(); }
}
