FROM alpine:3.15.0
LABEL maintainer="example@gmail.com"
RUN apk update && apk upgrade 
RUN apk add bash nginx openrc \
	&& mkdir -p /var/www/test_server \
	&& rm /etc/nginx/http.d/default.conf
COPY index.html /var/www/test_server
COPY test_server /etc/nginx/http.d/test_server.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
RUN openrc \
	&& touch /run/openrc/softlevel \
	&& rc-service nginx start
