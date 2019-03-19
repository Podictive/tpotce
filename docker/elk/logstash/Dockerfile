FROM docker.elastic.co/logstash/logstash-oss:6.6.1
USER root
RUN usermod -u 2000 logstash


# Include dist
ADD dist/ /tmp/dist/

# Setup env and apt
RUN yum install      -y       bash \
             curl \
             git \
             libc6-compat \
             libzmq \
             nss \
             openjdk8-jre \
             wget  && \

# Get and install packages
    git clone --depth=1 https://github.com/dtag-dev-sec/listbot /etc/listbot && \
    cd /tmp/dist/ && \
    wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz && \
    cd /tmp/dist/ && \
    cp update.sh /usr/bin/ && \
    chmod u+x /usr/bin/update.sh && \
    mkdir -p /etc/logstash/conf.d && \
    cp logstash.conf /etc/logstash/conf.d/ && \
    cp elasticsearch-template-es6x.json /usr/share/logstash/vendor/bundle/jruby/2.3.0/gems/logstash-output-elasticsearch-9.3.2-java/lib/logstash/outputs/elasticsearch/  && \
    chown -R logstash:logstash /etc/listbot && \
    chmod 755 /usr/bin/update.sh 


USER logstash
RUN /usr/share/logstash/bin/logstash-plugin install logstash-filter-translate && \
    /usr/share/logstash/bin/logstash-plugin install logstash-output-syslog
RUN    tar xvfz /tmp/dist/GeoLite2-ASN.tar.gz --strip-components=1 -C /usr/share/logstash/vendor/bundle/jruby/2.3.0/gems/logstash-filter-geoip-5.0.3-java/vendor/

# Healthcheck
HEALTHCHECK --retries=10 CMD curl -s -XGET 'http://127.0.0.1:9600'

# Start logstash
#USER logstash:logstash
CMD update.sh && exec /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf --config.reload.automatic --java-execution
