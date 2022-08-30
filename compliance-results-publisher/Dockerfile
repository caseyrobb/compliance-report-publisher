FROM registry.access.redhat.com/ubi9

user 0

RUN dnf install -y nginx bzip2 openscap-scanner && \
    dnf update -y && \
    dnf clean all && \
    mkdir -p /opt/nginx/html
    
ENV HOME=/opt/nginx

EXPOSE 8080
VOLUME /opt/nginx/html

ADD nginx.conf /opt/nginx/nginx.conf
ADD startup.sh /opt/nginx/
ADD bootstrap /opt/nginx/bootstrap

RUN chmod -R 775 /opt/nginx
   
CMD /opt/nginx/startup.sh

user 1001
