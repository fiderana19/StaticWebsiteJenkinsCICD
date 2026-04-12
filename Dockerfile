FROM nginx:latest

LABEL AUTHOR="Antsa Fiderana"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl git

RUN rm -rf /usr/share/nginx/html/*

RUN git clone https://github.com/fiderana19/static-website-example.git /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

CMD sed -i -e 's/$PORT'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
