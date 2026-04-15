FROM nginx:latest

LABEL AUTHOR="Antsa Fiderana"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl git

RUN rm -rf /usr/share/nginx/html/*

RUN git clone https://github.com/fiderana19/static-website-example.git /usr/share/nginx/html

EXPOSE 80

CMD nginx -g 'daemon off;'
