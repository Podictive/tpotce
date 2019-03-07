FROM docker.elastic.co/kibana/kibana-oss:6.5.4
USER root 
RUN usermod -u 2000 kibana

# Include dist
ADD dist/ /tmp/dist/

# Setup env and apt

# Add and move files
RUN     cd /tmp/dist/ && \
    cp kibana.svg /usr/share/kibana/src/ui/public/images/kibana.svg && \
    cp kibana.svg /usr/share/kibana/src/ui/public/icons/kibana.svg && \
    cp elk.ico /usr/share/kibana/src/ui/public/assets/favicons/favicon.ico && \
    cp elk.ico /usr/share/kibana/src/ui/public/assets/favicons/favicon-16x16.png && \
    cp elk.ico /usr/share/kibana/src/ui/public/assets/favicons/favicon-32x32.png && \
    cp create_kibana_index.js /usr/share/kibana/src/core_plugins/elasticsearch/lib/ && \

# Setup plugins, rebuild bundle
    #cd /usr/share/kibana/plugins && \
    #wget https://github.com/dlumbrer/kbn_radar/releases/download/Kibana-6.X/kbn_radar.tar.gz && \
    #wget https://github.com/dlumbrer/kbn_network/releases/download/6.0.X-1/network_vis.tar.gz && \
    #tar xvfz kbn_radar.tar.gz && \
    #tar xvfz network_vis.tar.gz && \
    #rm *.tar.gz && \
    rm -rf /usr/share/kibana/optimize/bundles/* && \
    /usr/share/kibana/bin/kibana-plugin install https://search.maven.org/remotecontent?filepath=com/floragunn/search-guard-kibana-plugin/6.5.4-18/search-guard-kibana-plugin-6.5.4-18.zip && \
    /usr/share/kibana/bin/kibana --optimize

# Setup user, groups and configs
RUN  sed -i 's/#server.basePath: ""/server.basePath: "\/kibana"/' /usr/share/kibana/config/kibana.yml && \
    sed -i 's/#kibana.defaultAppId: "home"/kibana.defaultAppId: "dashboards"/' /usr/share/kibana/config/kibana.yml && \
    sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /usr/share/kibana/config/kibana.yml && \
    sed -i 's/#elasticsearch.url: "https:\/\/localhost:9200"/elasticsearch.url: "http:\/\/elasticsearch:9200"/' /usr/share/kibana/config/kibana.yml && \
    sed -i 's/#server.rewriteBasePath: false/server.rewriteBasePath: false/' /usr/share/kibana/config/kibana.yml && \
    sed -i "s/#005571/#e20074/g" /usr/share/kibana/src/ui/public/chrome/directives/global_nav/global_nav.less && \
    sed -i "s/globalColorBlue/globalColorMagenta/g" /usr/share/kibana/src/ui/public/chrome/directives/global_nav/global_nav_link/global_nav_link.less && \
    echo "@globalColorMagenta: #9E0051;" >> /usr/share/kibana/src/ui/public/styles/variables/colors.less

# Healthcheck
HEALTHCHECK --retries=10 CMD curl -s -XGET 'http://127.0.0.1:5601'

# Start kibana
STOPSIGNAL SIGKILL
CMD ["/usr/share/kibana/bin/kibana"]
