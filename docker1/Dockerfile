FROM alpine:3.15.0
LABEL maintainer="example@gmail.com"
RUN apk update && apk upgrade && apk add bash && apk add nginx && apk add openrc
EXPOSE 80
CMD [echo, "'=====================test message========================='"]  
#RUN rc-service nginx start
#RUN service nginx start
