# Use OpenJDK 21 as base image
FROM openjdk:21-jdk-slim

# Copy the JAR file
COPY target/configserver-*.jar app.jar

# Expose port 8071
EXPOSE 8071

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
