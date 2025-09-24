# Use OpenJDK 21 as base image
FROM openjdk:21-jdk-slim

WORKDIR /app

# Copy the JAR file
COPY target/loans-*.jar loans.jar

# Expose port 8090
EXPOSE 8090

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8090/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "loans.jar"]
