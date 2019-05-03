FROM jupyter/datascience-notebook

MAINTAINER Olli Tourunen <olli.tourunen@csc.fi>

# Modified from pb-jupyter-datascience.dockerfile

USER $NB_USER

# Copy the requirements.txt file from pip to /opt/app
COPY requirements.txt /opt/app/requirements.txt

# Set working directory to /opt/app
WORKDIR /opt/app

# Upgrade pip and setuptools; install libraries from requirements.txt
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install -r requirements.txt --ignore-installed PyYAML

# Download spaCy models
RUN python -m spacy download en_core_web_sm
RUN python -m spacy download en_core_web_md
RUN python -m spacy download en_core_web_lg
RUN python -m spacy download en_vectors_web_lg

# Switch to root access
USER root

RUN apt update && apt install python-pkg-resources

USER root

# OpenShift allocates the UID for the process, but GID is 0
# Based on an example by Graham Dumpleton
RUN chgrp -R root /home/$NB_USER \
    && find /home/$NB_USER -type d -exec chmod g+rwx,o+rx {} \; \
    && find /home/$NB_USER -type f -exec chmod g+rw {} \; \
    && chgrp -R root /opt/conda \
    && find /opt/conda -type d -exec chmod g+rwx,o+rx {} \; \
    && find /opt/conda -type f -exec chmod g+rw {} \;

RUN ln -s /usr/bin/env /bin/env

ENV HOME /home/$NB_USER

COPY scripts/jupyter/autodownload_and_start.sh /usr/local/bin/autodownload_and_start.sh

# Set starting directory for the jupyter notebook
RUN mkdir -p /home/jovyan/work \
    && sed -i "s/#c.NotebookApp.notebook_dir =.*/c.NotebookApp.notebook_dir = '\/home\/jovyan\/work\/'/g" /home/jovyan/.jupyter/jupyter_notebook_config.py

RUN chmod a+x /usr/local/bin/autodownload_and_start.sh

# compatibility with old blueprints, remove when not needed
RUN ln -s /usr/local/bin/autodownload_and_start.sh /usr/local/bin/bootstrap_and_start.bash

USER 1000

# Copy the docker image creation files for reference
COPY . /opt/app

# Go back to student starting folder (e.g. the folder where you would also mount Rahti's persistant folder)
WORKDIR /home/$NB_USER/work

CMD ["/usr/local/bin/autodownload_and_start.sh"]
