FROM docker.elastic.co/elasticsearch/elasticsearch-oss:6.6.1
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install -b com.floragunn:search-guard-6:6.6.1-24.1
RUN usermod -u 2000 elasticsearch

ADD dist/ /root/dist/
RUN cp /root/dist/elasticsearch.yml /usr/share/elasticsearch/config/ && \
    rm -rf /usr/share/elasticsearch/modules/x-pack-ml

# Healthcheck
HEALTHCHECK --retries=10 CMD curl -s -XGET 'http://127.0.0.1:9200/_cat/health'

# Start ELK
USER elasticsearch:elasticsearch
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
