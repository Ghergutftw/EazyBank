package com.eazybytes.gatewayserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpMethod;

import java.time.Duration;
import java.time.LocalDateTime;

@SpringBootApplication
@EnableDiscoveryClient
public class GatewayserverApplication {

    public static void main(String[] args) {
        SpringApplication.run(GatewayserverApplication.class, args);
    }

    //  You can also create this in application.properties with in Java you can have more granular control
//  and create more complex filters that with plain yml
    @Bean
    public RouteLocator eazyBankRouteConfig(RouteLocatorBuilder routeLocatorBuilder) {
        return routeLocatorBuilder.routes()
                .route(p -> p
                        .path("/eazybank/accounts/**")
                        .filters(f -> f.rewritePath("/eazybank/accounts/(?<segment>.*)", "/${segment}")
                                .addResponseHeader("X-Response-Time", LocalDateTime.now().toString())
                                .circuitBreaker(config -> config.setName("accountsCircuitBreaker")
                                        .setFallbackUri("forward:/contactSupport"))
                                .addResponseHeader("X-Connect-Timeout", "1000")
                                .addResponseHeader("X-Response-Timeout", "2s")
//                                .requestRateLimiter(config -> config.setRateLimiter(redisRateLimiter())
//                                        .setKeyResolver(userKeyResolver()))
                                .retry(
                                        retryConfig -> {
                                            retryConfig.setRetries(3)
                                                    .setMethods(HttpMethod.GET)
                                                    .setBackoff(
                                                            Duration.ofMillis(100),Duration.ofMillis(1000),2,true
                                                    );
                                        }
                                )

                        )
                        .uri("http://accounts:8080")
                )
                .route(p -> p
                        .path("/eazybank/loans/**")
                        .filters(f -> f.rewritePath("/eazybank/loans/(?<segment>.*)", "/${segment}")
                                .addResponseHeader("X-Response-Time", LocalDateTime.now().toString())
                                .circuitBreaker(config -> config.setName("loansCircuitBreaker")
                                        .setFallbackUri("forward:/contactSupport"))
                                .addResponseHeader("X-Connect-Timeout", "1000")
                                .addResponseHeader("X-Response-Timeout", "2s")
//                                .requestRateLimiter(config -> config.setRateLimiter(redisRateLimiter())
//                                        .setKeyResolver(userKeyResolver()))
                                .retry(
                                        retryConfig -> {
                                            retryConfig.setRetries(3)
                                                    .setMethods(HttpMethod.GET)
                                                    .setBackoff(
                                                            Duration.ofMillis(100), Duration.ofMillis(1000), 2, true
                                                    );
                                        }
                                )
                        )
                        .uri("http://loans:8090"))
                .route(p -> p
                        .path("/eazybank/cards/**")
                        .filters(f -> f.rewritePath("/eazybank/cards/(?<segment>.*)", "/${segment}")
                                .addResponseHeader("X-Response-Time", LocalDateTime.now().toString())
                                .circuitBreaker(config -> config.setName("cardsCircuitBreaker")
                                        .setFallbackUri("forward:/contactSupport"))
                                .addResponseHeader("X-Connect-Timeout", "1000")
                                .addResponseHeader("X-Response-Timeout", "2s")
//                                .requestRateLimiter(config -> config.setRateLimiter(redisRateLimiter())
//                                        .setKeyResolver(userKeyResolver()))
                                .retry(
                                        retryConfig -> {
                                            retryConfig.setRetries(3)
                                                    .setMethods(HttpMethod.GET)
                                                    .setBackoff(
                                                            Duration.ofMillis(100), Duration.ofMillis(1000), 2, true
                                                    );
                                        }
                                )
                        )
                        .uri("http://cards:9000")).build();
        //This has to be with UPPERCASE because it reads the values from eureka where the default is with UPPERCASE

    }

//    @Bean
//    public Customizer<ReactiveResilience4JCircuitBreakerFactory> defaultCustomizer() {
//        return factory -> factory.configureDefault(id -> new Resilience4JConfigBuilder(id)
//                .circuitBreakerConfig(CircuitBreakerConfig.ofDefaults())
//                .timeLimiterConfig(TimeLimiterConfig.custom().timeoutDuration(Duration.ofSeconds(4)).build()).build());
//    }

//    @Bean
//    public RedisRateLimiter redisRateLimiter() {
//        return new RedisRateLimiter(1, 1, 1);
//    }
//
//    @Bean
//    KeyResolver userKeyResolver() {
//        //Who send the request from somewhere
//        return exchange -> Mono.justOrEmpty(exchange.getRequest().getHeaders().getFirst("user"))
//                .defaultIfEmpty("anonymous");
//    }

}