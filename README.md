# Using CSC services for teaching at Finnish universities

This repository contains instructions for setting up and running courses at Finnish universities that use services provided by [CSC – IT Centre for Science](https://www.csc.fi/). 

The instructions have been written at the University of Helsinki, but should be applicable to any institution in Finland with access to CSC services. 

A typical scenario for using CSC services might involve using [Jupyter Notebooks](https://www.csc.fi/home) for integrating teaching materials and interactive programming using the [cloud computing infrastructure at CSC](https://notebooks.csc.fi). 

This does not require setting up development environments on the students' own computers, allowing the teacher to focus on teaching instead of maintaining complex dependencies between libraries in various different environments. 

Services such as [GitHub](https://www.github.com) may be used to host and distribute course materials and assignments.

## Prerequisites

### Permissions

*For CSC*

- [ ] [Register for a CSC account](https://sui.csc.fi/web/guest/register) via the Scientist's User Interface (SUI). Log in using your HAKA Federation account (that is, your university account).

- [ ] [Apply for a new CSC project](https://sui.csc.fi/group/sui/resources-and-applications/-/applications/academic-csc-project).

- [ ] [Apply for cPouta cloud service access](https://sui.csc.fi/group/sui/resources-and-applications/-/applications/cpouta) for your project.

- [ ] [Request a new course](https://www.webropolsurveys.com/S/84118B6BD6E97501.par) on [CSC Notebooks](https://notebooks.csc.fi).

- [ ] If you plan to set up a custom environment for the course with specific libraries (e.g. spaCy and NLTK for natural language processing in Python), apply for access to the CSC Rahti platform by e-mailing *rahti-support (at) csc.fi)*. Mention your CSC username, which you can find under **My Account** on SUI and your CSC project ID, which you can find under **eService** &rarr; **My Projects**.

*For GitHub*

- [ ] Sign up for a GitHub account and apply for an [educational discount](https://help.github.com/en/articles/applying-for-an-educator-or-researcher-discount). This discount allows you to create unlimited private repositories. Note that verifying your eligibility for discount may take up to five days.

- [ ] Sign up for [GitHub classroom](https://classroom.github.com/). This is where you will set up individual and group assignments for students.

## Building your custom Docker image

This section explains how to create custom [Docker](https://www.docker.com/) images for the CSC Notebooks platform. Note that these instructions assume that you are familiar with using CSC Pouta cloud service. The instructions for using Pouta are available [here](https://research.csc.fi/pouta-user-guide).

### 1. Create a new project on the Rahti platform

Log in on the [Rahti platform web interface](https://rahti.csc.fi:8443/) using a web browser. Choose **CSC account** and enter your credentials.

### 2. Install Docker and OpenShift Command Line Interface

Login on your Pouta server.

- [ ] [Install Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) on your Pouta server

- [ ] [Install OpenShift](https://www.okd.io/download.html) Command Line Interface (CLI) on your Pouta server

Enter the following commands to install prerequisites for the OpenShift CLI:
```
sudo apt -y install python-pip && pip install --upgrade pip && pip install python-swiftclient
sudo apt-get -y install python-setuptools
sudo pip install python-keystoneclient
```
Then download the OpenShift CLI – check the Open Source Kubernetes Distribution website for the [latest version](https://www.okd.io/download.html).

Enter the following commands to install the OpenShift CLI. Note that these commands pertain to the current version – adjust the filename accordingly.
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

### 3. Create a Python virtual environment

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

### 4. Install the required libraries

Install the libraries required for your environment and their dependencies.

For example, install Python libraries for natural language processing, such as [spaCy](https://spacy.io/) and [NLTK](http://nltk.org/), by entering the following commands: 
```
pip install spacy
pip install nltk
```

### 5. Create a file that lists all libraries in the virtual environment

Once you have finished installing the required libraries, enter the following command to create a file named `requirements.txt`:
```
pip freeze > requirements.txt
```
This file contains information on all the libraries and their dependencies currently installed for the Python 3 virtual environment.

The file will be used to install these libraries into the Docker image.

Note that as of April 2019, Ubuntu has a bug which adds a non-existent library to the requirements file exported from `pip` using `pip freeze`.

To prevent the bug from raising an error, enter the following command to edit `requirements.txt`:
```
nano requirements.txt
```
Scroll down to the line containing `pkg-resources==0.0.0` and press <kbd>Control</kbd>+<kbd>k</kbd> to delete the line.

As of April 2019, another problem emerges from conflicting versions of the [NumPy](https://www.numpy.org/) library.

Fix this problem by finding the line containing `numpy==1.16.2` and changing the line to `numpy==1.15.4`.

Press <kbd>Control</kbd>+<kbd>x</kbd> followed by <kbd>y</kbd> to exit `nano` and save the changes.

### 6. Clone the repository containing images for CSC Notebooks

CSC provides [a repository](https://github.com/CSCfi/notebook-images) with example Dockerfiles, which define the environment to be created.

Clone this repository to your Pouta instance using `git` by entering the following command:
```
git clone https://github.com/CSCfi/notebook-images
```
In addition to example Dockerfiles in the directory `builds`, the repository contains scripts for building the Docker images and uploading them to CSC servers.

### 7. Define a Dockerfile and build the Docker image

The custom environment for CSC Notebooks is defined in a Dockerfile. For an example, see [`examples/pb-jupyter-nlp.dockerfile`](examples/pb-jupyter-nlp.dockerfile) in this repository.

Place the Dockerfile and your `requirements.txt` file created in step 4 into the subdirectory `builds` in the `notebooks-images` repo cloned in step 5.

Change to the directory `builds` by entering the command `cd builds`.

Next, execute the following command to build the docker image on your Pouta server:
```
sh build.sh <dockerfile-name-without-extension>
```
For example, to build the Dockerfile in the examples directory of this repository, the command would be as follows:
```
sh build.sh pb-jupyter-nlp
```
Note that the build process takes some time – be patient.

### 8. Upload the Docker image on the Rahti platform

To ensure the images are associated with your project, you first need to set up two local variables by entering the following commands on your Pouta instance:
```
export OSO_PROJECT=<name-of-your-project>
export OSO_REGISTRY=docker-registry.rahti.csc.fi
```
To exemplify, the `OSO_PROJECT` variable for my NLP course was set using the command `export OSO_PROJECT=uh-eng-nlp`. Note that the project name is not wrapped in less-than `<` and greater-than `>` characters.

Next, switch to the [Rahti platform web interface](https://rahti.csc.fi:8443/). Choose **CSC account** and enter your credentials.

In the Rahti main view, click your name on the upper right-hand corner and choose **Copy Login Command**.

This copies a login command for OpenShift CLI on your clipboard, which includes a token for authenticating with the Rahti platform. Paste the login command on your Pouta instance by pressing <kbd>Control</kbd>+<kbd>v</kbd> and press <kbd>Enter</kbd> to log in on the Rahti platform.
```
oc login https://rahti.csc.fi:8443 --token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
Note that the token is like a password and should be kept private.

Next, login to the Rahti registry via docker by entering the following command:
```
docker login -u ignored -p $(oc whoami -t) $OSO_REGISTRY
```
Finally, make sure you are in the `builds/` directory that contains your Dockerfile and the pre-built Docker image, and execute the following command to upload the image to OpenShift:
```
./build_and_upload_to_openshift.bash <name-of-your-dockerfile>
```
This will upload the Docker image to the Rahti platform.

### 9. Deploy the image on the Rahti platform

Open the [Rahti platform web interface](https://rahti.csc.fi:8443/) and select the project set up in step 1.

Click on **Deploy Image** in the main window in the middle.

Select **Image Stream Tag**. Select your project from drop-down menu for *Namespace*. Then select your image name from the next drop-down menu for *Image Stream*. Finally, enter `latest` in the *Tag* menu and press <kbd>Tab</kbd>.

You should now see the image you built in step 8 below.

Check the **Name** of the image in case the **Deploy** button remains inactive. The name of the image may contain only alphanumeric characters.

When ready, click **Deploy** to deploy the image.

### 10. Create a route to the image for CSC Notebooks

If the image is deployed successfully, the main view should now show the deployment configuration.

Click **Create Route** from the lower right-hand side to create a route to the image.

A window with options opens. Click **Create** to create the route.

You should then see your deployment running in the main window.

To expand the details for your deployment, click **>** on the left-hand side of the deployment name.

### 11. Associate a persistent storage with the image

If you want the students' work to be saved after shutting down a CSC Notebook, you need to request a persistent storage to be associated with each instance.

To do so, click **Applications** in the left-hand menu and choose **Deployments**. Then select your current deployment by clicking it's name in the main view.

Open the **Actions** menu on the top right-hand size and choose **Add Storage**.

If no persistent volume exists, choose **Create Storage**.

Enter a **Name** for the volume, choose *Single User (RWO)* for **Access Mode** and determing the size of the permanent volume by filling in the information under **Size**.  

### 12. Warm up the cache on Rahti

Because the images may be fairly big in size (e.g. 7GB), the students may experience delay when launching the instance.

To reduce this delay after deploying or updating an image, warm up the image cache by spinning up multiple copies of the instance. This ensures that the new or updated image is present on each instance before it is launched.

To do so, click **Applications** in the left-hand menu and choose **Deployments**. Then select your current deployment by clicking its name in the main view.

This will open the *History* tab showing your deployment history. Select the deployment with *Active* status by clicking the associated number, e.g. #2.

This opens the **Details** view. Adjust the number of **Replicas** by editing the corresponding value or use the selector on the right-hand size. Increase the number of replicas to match the number of students expected to attend the class.

The running replicas will be listed under *Pods* below. When all replicas are running, reduce the number of replicas back to one, as the image has been pre-loaded on all replicas.

### 13. Set Docker registry to allow anonymous access

Login to the [Rahti Docker registry](https://registry-console.rahti.csc.fi/) using your CSC account.

Click **Images** on the left-hand menu and select your current project by clicking its name in the main view.

This opens the **Image Stream** view. Ensure that *Access Policy* is set to "Images may be pulled by anonymous users" to allow CSC Notebooks to access the image. Click the name of the *Access Policy* to change the policy if necessary.

# Setting up a group on CSC Notebooks

TODO

# Setting up a course on GitHub Classroom

Jacob Fiksel has written two excellent guides for using GitHub Classroom for both [teachers](https://github.com/jfiksel/github-classroom-for-teachers) and [students](https://github.com/jfiksel/github-classroom-for-students).

Follow the instructions for teachers to set up the course organisation.
