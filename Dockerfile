FROM diamol/maven AS MAVEN_BUILD

COPY  tenant-service-impl/pom.xml /build/
COPY settings.xml /build/

COPY tenant-service-impl/src /build/src/

WORKDIR /build/
RUN mvn -s settings.xml clean install -U -Pstaging -Dmaven.test.skip=true && mvn package -B -e -Pstaging


FROM adoptopenjdk/openjdk11:jdk-11.0.9.1_1-alpine-slim


WORKDIR /app

COPY --from=MAVEN_BUILD /build/target/tenant-*.jar /app/appdemo.jar

EXPOSE 8082
CMD ["java","-jar","/app/appdemo.jar"]