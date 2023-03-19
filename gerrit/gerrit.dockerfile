FROM gerritcodereview/gerrit:$GERRIT_VERSION.$GERRIT_PATCH-almalinux8

USER root

RUN  yum install -y python36 python3-libs python36-devel python3-pip gcc openssl-devel bzip2-devel wget make

COPY --chown=gerrit:gerrit ssh-config /var/gerrit/.ssh/config

# Installing scripts to get SSH Keys from Secret Manager
COPY --chown=gerrit:gerrit requirements.txt /tmp
COPY --chown=gerrit:gerrit setup_gerrit.py /tmp
RUN chmod +x /tmp/setup_gerrit.py \
    && pip3 install -r /tmp/requirements.txt

# Gerrit Webhook: Installing Python2
WORKDIR /usr/src

RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz \
    && tar xzf Python-2.7.18.tgz

WORKDIR /usr/src/Python-2.7.18

RUN ./configure --enable-optimizations \ 
    && make altinstall \
    && curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py" -o "get-pip.py" \
    &&  python2.7 get-pip.py \
    && ln -s /usr/local/bin/python2.7 /usr/local/bin/python2
   
# Gerrit Webhook: Installing Jenkins Module
RUN pip2 install python-jenkins 

# Gerrit Webhook: Adding Scripts to Docker Image
RUN mkdir /var/gerrit/hooks/
COPY --chown=gerrit:gerrit  patchset-created commit-received /var/gerrit/hooks/
RUN chmod +x /var/gerrit/hooks/patchset-created /var/gerrit/hooks/commit-received

USER gerrit

COPY --chown=gerrit:gerrit plugins /var/gerrit/plugins
COPY --chown=gerrit:gerrit lib /var/gerrit/lib
COPY --chown=gerrit:gerrit etc /var/gerrit/etc

# Install AWS cli
RUN pip3 install awscli --upgrade --user
ENV PATH ${PATH}:/var/gerrit/.local/bin

WORKDIR /var/gerrit

COPY ./entrypoint.sh /bin

ENTRYPOINT ["sh", "/bin/entrypoint.sh"]
