FROM tomcat:8.0-alpine
LABEL maintainer="mavrick202@gmail.com"
ADD ROOT*.war /usr/local/tomcat/webapps/
RUN mv /usr/local/tomcat/webapps/*.war /usr/local/tomcat/webapps/mywebapp.war
EXPOSE 8080
CMD ["catalina.sh","run"]