FROM maven:3.9.11-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src src
RUN mvn -B -q package -DskipTests
FROM eclipse-temurin:21-jre
RUN addgroup --system novalearn && adduser --system --ingroup novalearn novalearn
WORKDIR /app
COPY --from=build /workspace/target/novalearn-api-*.jar app.jar
USER novalearn
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
