# centos:ssh
#
# VERSION               0.0.1
  
  FROM centos
    
#ssh
    RUN yum install -y openssh openssh-server openssh-clients wget && \
        mkdir /var/run/sshd && \
        ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key && \
        ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key && \
        sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config && \
        sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config && \
        /bin/echo 'root:123456' |chpasswd && \
        /bin/sed -i 's/.*session.*required.*pam_loginuid.so.*/session optional pam_loginuid.so/g' /etc/pam.d/sshd && \
        /bin/echo -e "LANG=\"en_US.UTF-8\"" > /etc/default/local
      
#tomcat
    ADD apache-tomcat-7.0.41.tar.gz /usr/local/src/
    WORKDIR /usr/local/src/
    RUN wget https://mirror.its.sfu.ca/mirror/CentOS-Third-Party/NSG/common/x86_64/jdk-7u80-linux-x64.rpm && \
        rpm -ivh jdk-7u80-linux-x64.rpm
    ENV JAVA_HOME /usr/java/jdk1.7.0_80
    ENV PATH $PATH:$JAVA_HOME/bin
    ENV CLASSPATH .:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
#RUN java -version
    RUN mkdir -p /usr/local/tools && \
        cp -r apache-tomcat-7.0.41 /usr/local/tools/tomcat7_8080
        
# cp python script
    COPY test_python.py /usr/local/src/test_python.py

#supervisor
    RUN rpm -Uvh https://mirrors.ustc.edu.cn/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm && \
        yum update;yum -y install supervisor && \
        mkdir -p /etc/supervisor/
    COPY supervisord.conf /etc/supervisor/
      
    EXPOSE 22 9001 8080
    CMD supervisord -c /etc/supervisor/supervisord.conf
