# ---------- BUILD STAGE ----------
FROM maven:3.8.1-openjdk-8 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests


# ---------- RUNTIME STAGE ----------
FROM tomcat:9.0.53-jdk8

# Remove default apps (clean Tomcat)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR as ROOT app
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
