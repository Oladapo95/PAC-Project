#FROM openjdk:11-jre-slim
FROM tomcat
RUN mkdir -p /home/app
COPY ./spring-petclinic-2.4.2.war /home/app
WORKDIR /home/app
ENTRYPOINT [ "java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085" ]

