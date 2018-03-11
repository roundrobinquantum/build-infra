FROM nginx:1.12-alpine
COPY nginx.conf /etc/nginx/nginx.conf

ARG HOST_IP

RUN sed -i 's/HOST_IP/'"${HOST_IP}"'/g' /etc/nginx/nginx.conf
RUN nginx -t
