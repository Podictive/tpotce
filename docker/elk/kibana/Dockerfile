FROM docker.elastic.co/kibana/kibana-oss:6.6.1
USER root
RUN usermod -u 2000 kibana
USER kibana
# Setup env and apt

# Setup plugins, rebuild bundle
RUN rm -rf /usr/share/kibana/optimize/bundles/* && \
    /usr/share/kibana/bin/kibana-plugin install https://search.maven.org/remotecontent?filepath=com/floragunn/search-guard-kibana-plugin/6.6.1-18.1/search-guard-kibana-plugin-6.6.1-18.1.zip && \
    /usr/share/kibana/bin/kibana --optimize

# Include dist
ADD dist/ /tmp/dist/
# Add and move files
RUN cd /tmp/dist/ && \
    cp kibana.yml /usr/share/kibana/config/kibana.yml && \
    cp kibana.svg /usr/share/kibana/src/ui/public/images/kibana.svg && \
    cp kibana.svg /usr/share/kibana/src/ui/public/icons/kibana.svg && \
    cp elk.ico /usr/share/kibana/src/ui/public/assets/favicons/favicon.ico && \
    cp elk.ico /usr/share/kibana/src/ui/public/assets/favicons/favicon-16x16.png && \
    cp elk.ico /usr/share/kibana/src/ui/public/assets/favicons/favicon-32x32.png

# Setup user, groups and configs
RUN sed -i "s/#005571/#e20074/g" /usr/share/kibana/src/ui/public/chrome/directives/global_nav/global_nav.less && \
    sed -i "s/globalColorBlue/globalColorMagenta/g" /usr/share/kibana/src/ui/public/chrome/directives/global_nav/global_nav_link/global_nav_link.less && \
    echo "@globalColorMagenta: #9E0051;" >> /usr/share/kibana/src/ui/public/styles/variables/colors.less

# Healthcheck
HEALTHCHECK --retries=10 CMD curl -s -XGET 'http://127.0.0.1:5601'
