# Using CSC services at UH

This repository contains instructions for setting up and running courses at the University of Helsinki that use services provided by [CSC – IT Centre for Science](https://www.csc.fi/).

A typical scenario might involve using [Jupyter Notebooks](https://www.csc.fi/home) for teaching materials and interactive programming using the [cloud computing infrastructure at CSC](https://notebooks.csc.fi).

## Prerequisites

### Permissions

*For CSC*

- [ ] [Register for a CSC account](https://sui.csc.fi/web/guest/register) via the Scientist's User Interface (SUI). Use your HAKA Federation login (that is, your university login) to authenticate with the service.

- [ ] [Apply for a new CSC project](https://sui.csc.fi/group/sui/resources-and-applications/-/applications/academic-csc-project).

- [ ] [Apply for cPouta cloud service access](https://sui.csc.fi/group/sui/resources-and-applications/-/applications/cpouta).

- [ ] Apply for group administrator rights for CSC Notebooks by e-mailing *servicedesk (at) csc.fi*. Write that you are using CSC Notebooks for teaching and require group administrator rights. Mention your CSC username, which you can find under *My Account* on the top-right corner of the Scientist's User Interface (SUI).

- [ ] Apply for access to the CSC Rahti platform if you plan to set up a custom environment for the course with specific libraries (e.g. spaCy and NLTK for natural language processing in Python) by e-mailing *rahti-support (at) csc.fi)*. Mention your CSC username, which you can find under **My Account** on SUI and your CSC project ID, which you can find under **eService** &rarr; **My Projects**.

*For GitHub*

- [ ] Sign up for a GitHub account and apply for an [educational discount](https://help.github.com/en/articles/applying-for-an-educator-or-researcher-discount). This discount allows you to create unlimited private repositories. Note that verifying your eligibility for discount may take up to five days.

- [ ] Sign up for [GitHub classroom](https://classroom.github.com/). This is where you will set up individual and group assignments for students.

## Guides

- Setting up a group on PB Notebooks: http://cscfi.github.io/pebbles/group_owners_guide.html

## Building your custom docker image

This section explains how to create custom [Docker](https://www.docker.com/) images for the CSC Notebooks platform. Note that these instructions assume that you are familiar with using CSC Pouta cloud service. The instructions for using Pouta are available [here](https://research.csc.fi/pouta-user-guide).

### 1. Install Docker and OpenShift Command Line Interface 

- [ ] [Install Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) on your Pouta server

- [ ] [Install OpenShift](https://www.okd.io/download.html) Command Line Interface (CLI) on your Pouta server

Enter the following commands to install prerequisites for the OpenShift CLI:
```
sudo apt -y install python-pip && pip install --upgrade pip && pip install python-swiftclient
sudo apt-get -y install python-setuptools
sudo pip install python-keystoneclient
```
Then download the OpenShift CLI – check the Open Source Kubernetes Distribution website for the [latest version](https://www.okd.io/download.html).

Enter the following commands to install the OpenShift CLI:
```
wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar -xvzf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
chmod +x openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc
sudo mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/sbin
```
Verify the installation by calling `oc` from the command line:
```
oc --help
```

### 2. Create a Python virtual environment

- [ ] Create a Python 3 virtual environment

To create a Python 3 virtual environment named `course-env` in your home directory enter the following command:
```
python3 -m venv ~/course-env
```
To activate the virtual environment, enter the following command:
```
source ~/course-env/bin/activate
```
You should now see `(course-env)` in front of your command line prompt.

Next, enter the following commands to update the tools for installing Python packages:
```
pip install --upgrade pip
pip install --upgrade setuptools
```

### 3. Install the required libraries




- install the required packages
- use `pip freeze > requirements.txt`
- clean requirements.txt (remove pkg-resources=0.0.0 and install numpy=1.15.4)
- clone the CSC notebooks repo
- place your dockerfile and requirements.txt in the directory `/builds/`
- build the dockerfile

- set two local variables on your Pouta instance:
```
export OSO_PROJECT=<name-of-your-project>
export OSO_REGISTRY=docker-registry.rahti.csc.fi
```
- copy login command from Rahti
- login to rahti via OC
- login to Rahti registry via docker
```docker login -u ignored -p $(oc whoami -t) $OSO_REGISTRY```
- build and upload the image to openshift

- create Rahti deployment and warm up the cache by spinning up some ~20 pods
- set docker registry to anonymous
- create an image for the group on Notebooks

## TODO

- Find out how to set up permanent storage on Notebooks
