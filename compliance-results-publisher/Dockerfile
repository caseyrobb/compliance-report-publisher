FROM ubi9/ubi-minimal

RUN microdnf install -y nginx bzip2 openscap-scanner && \
    microdnf update -y && \
    microdnf clean all && \
    mkdir -p /opt/nginx/html
    
ENV HOME=/opt/nginx

EXPOSE 8080
VOLUME /opt/nginx/html

ADD nginx.conf /opt/nginx/nginx.conf
ADD startup.sh /opt/nginx/
ADD bootstrap /opt/nginx/bootstrap

RUN chmod -R 775 /opt/nginx
   
user 1001

CMD /opt/nginx/startup.sh
