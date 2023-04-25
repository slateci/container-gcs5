FROM rockylinux:9
LABEL maintainer sthapa@uchicago.edu

RUN dnf update -y

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm &&  \
     dnf install -y https://downloads.globus.org/globus-connect-server/stable/installers/repo/rpm/globus-repo-latest.noarch.rpm
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf install -y globus-connect-server54


ENTRYPOINT ["/usr/local/bin/supervisord_startup.sh"]

