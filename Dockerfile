FROM rockylinux:9
LABEL maintainer sthapa@uchicago.edu

RUN dnf update -y

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm &&  \
     dnf install -y https://downloads.globus.org/globus-connect-server/stable/installers/repo/rpm/globus-repo-latest.noarch.rpm
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf install -y globus-connect-server54 sudo procps-ng
COPY scripts/gcs-setup.sh /usr/local/bin/gcs-setup.sh
COPY scripts/setup-passwd.sh /usr/local/bin/setup-passwd.sh
COPY scripts/configure-endpoint.sh /usr/local/bin/configure-endpoint.sh
COPY scripts/stop-endpoint.sh /usr/local/bin/stop-endpoint.sh

# These are the default ports in use by GCSv5.4. Currently, they can not be changed.
#   443 : HTTPD service for GCS Manager API and HTTPS access to collections
#  50000-51000 : Default port range for incoming data transfer tasks
EXPOSE 443/tcp 50000-51000/tcp

ENTRYPOINT ["/usr/local/bin/gcs-setup.sh"]

