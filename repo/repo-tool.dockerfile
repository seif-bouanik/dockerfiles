# Dockerfile to run git Repo tool in a container.
FROM python:3.9

# CREATING USER
ENV HOME=/home/repo
RUN useradd --create-home --home-dir $HOME repo \
    && chown -R repo:repo $HOME
USER repo
WORKDIR $HOME

# INSTALLING REPO TOOL
RUN mkdir -p .bin && \
    curl https://storage.googleapis.com/git-repo-downloads/repo > .bin/repo && \
    chmod a+rx .bin/repo \
    && export PATH=$PATH:$HOME/.bin


ENTRYPOINT ["/bin/bash", "-l", "-c", "/bin/bash"]