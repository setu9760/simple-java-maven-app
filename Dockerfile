FROM openjdk:8-jdk-alpine

ADD /target/${ARTIFACT_ID}-${REVISION}.jar ${ARTIFACT_ID}.jar

ENTRYPOINT ["java","-jar","/${ARTIFACT_ID}.jar"]
