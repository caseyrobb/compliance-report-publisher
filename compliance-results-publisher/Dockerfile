FROM ubi9/ubi-minimal

ENV APPHOME=/opt/nginx
#ENV DEBUG="true"

RUN microdnf install -y nginx bzip2 openscap-scanner && \
    microdnf update -y && \
    microdnf clean all && \
    mkdir -p $APPHOME/html 
    
COPY files/* $APPHOME
RUN chmod -R 775 $APPHOME && chown -R 1001:1001 $APPHOME 

EXPOSE 8080
   
USER 1001
VOLUME $APPHOME/html

CMD ["/opt/nginx/startup.sh"]
