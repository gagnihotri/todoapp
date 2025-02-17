# Use Eclipse Temurin JRE 17 for a lightweight runtime
FROM eclipse-temurin:17-jre AS runtime

# Set the working directory
WORKDIR /app

# Copy the JAR file from the current directory to the container
COPY target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
