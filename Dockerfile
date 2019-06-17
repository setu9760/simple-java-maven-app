FROM openjdk:8-jdk-alpine

ARG ARTIFACT_ID
ARG REVISION

ADD /target/${ARTIFACT_ID}-${REVISION}.jar ${ARTIFACT_ID}.jar

ENTRYPOINT ["java","-jar","/${ARTIFACT_ID}.jar"]
