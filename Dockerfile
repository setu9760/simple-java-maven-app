FROM openjdk:8-jdk-alpine

ARG ARTIFACT_ID=simple-java-maven-app
ARG REVISION

ADD /target/${ARTIFACT_ID}-${REVISION}.jar ${ARTIFACT_ID}.jar

ENTRYPOINT ["java","-jar","/${ARTIFACT_ID}.jar"]
