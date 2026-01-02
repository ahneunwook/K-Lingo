package com.kdopamine.app.global.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class SwaggerConfig {

    @Value("${spring.application.name}")
    private String applicationName;

    @Value("${server.port}")
    private String serverPort;

    @Value("${server.servlet.context-path}")
    private String contextPath;

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(apiInfo())
                .servers(servers())
                .components(securityComponents())
                .addSecurityItem(securityRequirement());
    }

    private Info apiInfo() {
        return new Info()
                .title(applicationName + " API")
                .description("Korean-Mate REST API Documentation")
                .version("v1.0.0")
                .contact(new Contact()
                        .name("Korean-Mate Team")
                        .email("contact@kdopamine.com")
                        .url("https://github.com/kdopamine"))
                .license(new License()
                        .name("Private")
                        .url(""));
    }

    // Swagger UI에서 API 테스트할 서버를 선택할 수 있음
    private List<Server> servers() {
        Server localServer = new Server()
                .url("http://localhost:" + serverPort + contextPath)
                .description("Local Development Server");

//        Server prodServer = new Server()
//                .url("https://api.kdopamine.com" + contextPath)
//                .description("Production Server");

        return List.of(localServer);
    }

    private Components securityComponents() {
        return new Components()
                .addSecuritySchemes("bearerAuth",
                        new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .in(SecurityScheme.In.HEADER)
                                .name("Authorization"));
    }

    private SecurityRequirement securityRequirement() {
        return new SecurityRequirement().addList("bearerAuth");
    }
}

