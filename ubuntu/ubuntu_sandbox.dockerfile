FROM ubuntu:18.04
LABEL maintainer="Seif"

# CHANGING TO TEMP FOLDER
WORKDIR /tmp

# COPYING NECESSARY PACKAGES LIST
COPY ubuntu_sandbox_packages_list.txt   .

#PACKAGES MANAGEMENT
RUN apt-get update -y \
    && apt-get upgrade -y \ 
    && xargs -n 1 -- apt install -y --ignore-missing < packages.txt

# GENERAL SSH CONFIG
EXPOSE 22
RUN service ssh start


# USERS MANAGEMENT
ENV USER=sbouanik
ENV HOME=/home/$USER
RUN useradd -s /bin/bash --create-home --home-dir $HOME $USER \
    && chown -R $USER:$USER $HOME \
    && usermod -aG sudo $USER
RUN echo 'root:10010110' | chpasswd
RUN echo 'sbouanik:10010110' | chpasswd
USER $USER
WORKDIR $HOME

# ADDING PERSONAL CONFIGS (AWS, GIT and BASHRC)
COPY ubuntu-sandbox/   $HOME

# USER SSH CONFIG
RUN mkdir $HOME/.ssh \
    && chmod 700 $HOME/.ssh

# SPECIFYING THE SHELL
ENTRYPOINT ["/bin/bash", "-l", "-c", "/bin/bash"]