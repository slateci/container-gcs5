FROM centos/systemd

RUN yum install -y epel-release
RUN yum update -y

RUN rpm --import https://downloads.globus.org/toolkit/gt6/stable/repo/rpm/RPM-GPG-KEY-Globus; \
    yum localinstall -y https://downloads.globus.org/toolkit/globus-connect-server/globus-connect-server-repo-latest.noarch.rpm; \
    yum-config-manager --enable Globus-Connect-Server-5-Stable -y; \
    yum-config-manager --enable Globus-Toolkit-6-Stable -y; \
    yum -y install globus-connect-server51; \
    yum -y install httpd; \
    yum clean all

RUN chown -R gcsweb: /var/www/

EXPOSE 80

RUN systemctl enable httpd.service

COPY app/globus-connect-server-setup.service /etc/systemd/system/

RUN systemctl enable globus-connect-server-setup.service

CMD ["/usr/sbin/init"]
