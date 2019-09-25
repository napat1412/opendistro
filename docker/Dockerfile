
#{% set tarball = 'elasticsearch-oss-%s-linux-x86_64.tar.gz' % elastic_version -%}

#{% if artifacts_dir %}
#{% set artifact_repo_url = 'file:///%s' % artifacts_dir -%}
#{% endif %}
################################################################################
# Build stage 0 `prep_es_files`:
# Extract elasticsearch artifact
# Install required plugins
# Set gid=0 and make group perms==owner perms
################################################################################

FROM amazon/opendistro-for-elasticsearch:1.1.0 AS prep_es_files
#FROM amazon/opendistro-for-elasticsearch:1.1.0

ENV PATH /usr/share/elasticsearch/bin:$PATH

#RUN yum install -y unzip
#RUN groupadd -g 1000 elasticsearch && \
#    adduser -u 1000 -g 1000 -d /usr/share/elasticsearch elasticsearch

USER 1000

WORKDIR /usr/share/elasticsearch

# Install the required modules
RUN elasticsearch-plugin remove opendistro_security
COPY releases/opendistro_security-1.1.0.3.zip /tmp
RUN elasticsearch-plugin install -b file:///tmp/opendistro_security-1.1.0.3.zip

# Make the certificate installer script executable. This script has to be executed before ES is started.
COPY tools/install_demo_configuration.sh /tmp/install_demo_configuration.sh
RUN cp /tmp/install_demo_configuration.sh /usr/share/elasticsearch/plugins/opendistro_security/tools/install_demo_configuration.sh
RUN chmod +x /usr/share/elasticsearch/plugins/opendistro_security/tools/*


################################################################################
# Build stage 1 (the actual opendistroforelasticsearch image):
# Copy opendistroforelasticsearch from stage 0
# Add entrypoint
################################################################################

FROM centos:7

ENV ELASTIC_CONTAINER true

RUN \
  rpm --rebuilddb && yum clean all && \
  yum install -y epel-release && \
  yum update -y && \
  yum install -y \
                  iproute \
                  python-setuptools \
                  hostname \
                  inotify-tools \
                  yum-utils \
                  which \
                  jq \
                  rsync && \
  yum clean all && \
  easy_install supervisor

RUN yum update -y && \
    yum install -y nc unzip wget which && \
    yum clean all
#COPY CENTOS_LICENSING.txt /root
COPY --from=prep_es_files --chown=1000:0 /opt/jdk-11.0.1 /opt/jdk-11.0.1
ENV JAVA_HOME /opt/jdk-11.0.1

# Replace OpenJDK's built-in CA certificate keystore with the one from the OS
# vendor. The latter is superior in several ways.
RUN ln -sf /etc/pki/ca-trust/extracted/java/cacerts /opt/jdk-11.0.1/lib/security/cacerts

ENV PATH $PATH:$JAVA_HOME/bin

RUN mkdir /usr/share/elasticsearch && \
    groupadd -g 1000 elasticsearch && \
    adduser -u 1000 -g 1000 -G 0 -d /usr/share/elasticsearch elasticsearch && \
    chmod 0775 /usr/share/elasticsearch && \
    chgrp 0 /usr/share/elasticsearch

RUN mkdir /usr/share/supervisor

WORKDIR /usr/share/elasticsearch
COPY --from=prep_es_files --chown=1000:0 /usr/share/elasticsearch /usr/share/elasticsearch
ENV PATH /usr/share/elasticsearch/bin:$PATH

#ADD --chown=1000:0 bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --from=prep_es_files --chown=1000:0 /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Openshift overrides USER and uses ones with randomly uid>1024 and gid=0
# Allow ENTRYPOINT (and ES) to run even with a different user
RUN chgrp 0 /usr/local/bin/docker-entrypoint.sh && \
    chmod g=u /etc/passwd && \
    chmod 0775 /usr/local/bin/docker-entrypoint.sh

EXPOSE 9200 9300 9600

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.name="opendistroforelasticsearch" \
  org.label-schema.version="{{ version_tag }}" \
  org.label-schema.url="https://opendistro.github.io" \
  org.label-schema.vcs-url="https://github.com/opendistro-for-elasticsearch/opendistro-build" \
  org.label-schema.license="Apache-2.0" \
  org.label-schema.vendor="Amazon" \
  org.label-schema.build-date="{{ build_date }}"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# Dummy overridable parameter parsed by entrypoint
CMD ["eswrapper"]

################################################################################
# End of multi-stage Dockerfile
################################################################################
