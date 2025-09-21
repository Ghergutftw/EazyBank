package com.eazybytes.accounts.interceptor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Component
@RefreshScope
public class MaintenanceInterceptor implements HandlerInterceptor {

    @Autowired
    private Environment environment;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Get the current value dynamically from the environment
        String maintenanceMode = environment.getProperty("app.maintenance", "false");

        // Add logging to see what value we're getting
        System.out.println("Maintenance mode check: " + maintenanceMode);

        if ("true".equalsIgnoreCase(maintenanceMode)) {
            response.setContentType("application/json");
            response.setStatus(503); // Service Unavailable

            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            String maintenanceMessage = String.format(
                """
                {
                  "status": "SERVICE_UNAVAILABLE",
                  "message": "EazyBank Accounts Service is currently under maintenance",
                  "details": "We are performing scheduled maintenance to improve our services. Please try again later.",
                  "timestamp": "%s",
                  "service": "accounts-service",
                  "supportContact": "support@eazybank.com",
                  "maintenanceValue": "%s"
                }""", timestamp, maintenanceMode
            );

            response.getWriter().write(maintenanceMessage);
            return false; // Stop processing
        }
        return true; // Continue to controller
    }
}
