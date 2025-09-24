package com.eazybytes.loans.interceptor;

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

    private static boolean lastMaintenanceState = false;
    private static boolean hasLoggedMaintenanceState = false;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Get the current value dynamically from the environment
        String maintenanceMode = environment.getProperty("app.maintenance", "false");
        boolean isMaintenanceMode = "true".equalsIgnoreCase(maintenanceMode);

        // Only log when maintenance state changes or when maintenance is enabled
        if (isMaintenanceMode != lastMaintenanceState || (isMaintenanceMode && !hasLoggedMaintenanceState)) {
            if (isMaintenanceMode) {
                System.out.println("🔧 LOANS SERVICE: Maintenance mode ENABLED");
            } else {
                System.out.println("✅ LOANS SERVICE: Maintenance mode DISABLED");
            }
            lastMaintenanceState = isMaintenanceMode;
            hasLoggedMaintenanceState = true;
        }

        if (isMaintenanceMode) {
            response.setContentType("application/json");
            response.setStatus(503); // Service Unavailable

            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            String maintenanceMessage = String.format(
                """
                {
                  "status": "SERVICE_UNAVAILABLE",
                  "message": "EazyBank Loans Service is currently under maintenance",
                  "details": "We are performing scheduled maintenance to improve our services. Please try again later.",
                  "timestamp": "%s",
                  "service": "loans-service",
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
