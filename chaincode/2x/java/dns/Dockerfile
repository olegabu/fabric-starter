ARG GRADLE_RUNTIME
ARG JAVA_RUNTIME
# the first stage
FROM ${GRADLE_RUNTIME:-gradle:jdk11} AS GRADLE_BUILD

# copy the build.gradle and src code to the container
COPY src/ src/
COPY build.gradle ./

# Build and package our code
RUN gradle build shadowJar


# the second stage of our build just needs the compiled files
FROM ${JAVA_RUNTIME:-openjdk:11-jre-slim}
# copy only the artifacts we need from the first stage and discard the rest
COPY --from=GRADLE_BUILD /home/gradle/build/libs/chaincode.jar /chaincode.jar

ENV PORT 9999
EXPOSE 9999

# set the startup command to execute the jar
CMD ["java", "-jar", "/chaincode.jar"]