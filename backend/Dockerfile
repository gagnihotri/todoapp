# Use Eclipse Temurin JRE 17 for a lightweight runtime
FROM eclipse-temurin:17-jre-alpine AS runtime

ARG RDS_DB_ENDPOINT
ARG RDS_DB_USERNAME
ARG RDS_DB_PASSWORD

# Set environment variables (optional)
ENV RDS_DB_ENDPOINT=$RDS_DB_ENDPOINT
ENV RDS_DB_USERNAME=$RDS_DB_USERNAME
ENV RDS_DB_PASSWORD=$RDS_DB_PASSWORD

# Set the working directory
WORKDIR /app

# Copy the JAR file from the current directory to the container
COPY target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
