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

- [ ] Apply for access to the Rahti platform if you plan to set up a custom environment for the course with specific libraries (e.g. spaCy and NLTK for natural language processing in Python) by e-mailing *rahti-support (at) csc.fi)*. Mention your CSC username, which you can find under **My Account** on SUI and your CSC project ID.

*For GitHub*

- [ ] Sign up for a GitHub account and apply for an [educational discount](https://help.github.com/en/articles/applying-for-an-educator-or-researcher-discount). This discount allows you to create unlimited private repositories. Note that verifying your eligibility for discount may take up to five days.

- [ ] Sign up for [GitHub classroom](https://classroom.github.com/). This is where you will set up individual and group assignments for students.

## Guides

- Setting up a group on PB Notebooks: http://cscfi.github.io/pebbles/group_owners_guide.html

## Building your own docker image

- install docker on your Pouta instance
- install OC command line tools

- create a Python virtual environment
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
