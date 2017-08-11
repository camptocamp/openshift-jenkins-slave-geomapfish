FROM camptocamp/geomapfish_build:jenkins

MAINTAINER Marc Sutter <marc.sutter@camptocamp.com>

ENV HOME=/home/jenkins-slave \
    JAVA_HOME=/usr/lib/jvm/java-8-oracle \
    PATH=$JAVA_HOME/bin:$PATH \
    JENKINS_SWARM_VERSION=3.4 \
    OPENSHIFT_CLIENT_VERSION=v1.5.0-031cbe4

USER root

# Update
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install software-properties-common && \
    apt-get clean

# Install headless Java (amd64 & i386)
RUN echo "deb http://http.debian.net/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y -t jessie-backports openjdk-8-jre-headless openjdk-8-jre-headless:i386 && \
    apt-get clean

# Install tools
RUN apt-get update && \
    apt-get install -y wget curl git gettext lsof ca-certificates && \
    apt-get clean

# Install openshift client
RUN curl -sSLO https://github.com/openshift/origin/releases/download/v1.5.0/openshift-origin-client-tools-$OPENSHIFT_CLIENT_VERSION-linux-64bit.tar.gz \
  && tar --strip-components=1 -xvf openshift-origin-client-tools-$OPENSHIFT_CLIENT_VERSION-linux-64bit.tar.gz -C /usr/local/bin \
  && chmod +x /usr/local/bin/oc \
  && rm -f openshift-origin-client-tools-$OPENSHIFT_CLIENT_VERSION-linux-64bit.tar.gz

# Create jenkins-user
RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave

# Modify access to needed resource for the run-jnlp-client script
RUN chmod 777 /etc/passwd && \
    chmod -R 777 /etc/alternatives && \
    chmod -R 777 /var/lib/dpkg/alternatives && \
    chmod -R 775 /usr/lib/jvm && \
    chmod 775 /usr/bin && \
    chmod 775 /usr/share/man/man1

# Copy the entrypoint
ADD contrib/bin/* /usr/local/bin/

# Run as jenkins-slave
USER jenkins-slave

# Run the Jenkins JNLP client
ENTRYPOINT ["/usr/local/bin/run-jnlp-client"]