# Lab 5 - Parsing Data
In this lab we're going to spin up a SageMaker domain.  We'll then use it to run a notebook that calls Neo4j and Amazon Bedrock APIs to load data into Neo4j.

## Create a SageMaker Domain
The first step is to deploy a SageMaker domain.  To do that, open the AWS console [here](https://console.aws.amazon.com/).  In the search bar, type "sagemaker." 

![](images/01.png)

From the search results, click on "SageMaker Studio" under "Top Features".

![](images/02.png)

Click the "Studio" link on the panel on the left.

![](images/03-0.png)

Now click the "Domains" link on the panel on the left under `Admin Configurations`.

If you don't see a domain created already, click "Create Domain"
![](images/03-1.png)

Click "Set up" in the Set up Sagemaker Domain page
![](images/03-2.png)

You will see the domain being created as below.
![](images/03-3.png)

It will take a few minutes to complete. Once done, you will see as below.
![](images/03-4.png)

Click on the domain name.

![](images/04.png)

Once it finishes, you'll see a message saying "The SageMaker Domain is ready."  Next to the default user, click "Launch" and select "Studio" under that.  You'll be put through a few redirects.

If the default user isn't shown, you may need to refresh the screen.
You will be landing in the Studio screen below.
![](images/05-0.png)

Click on the button with orange background - "Jupyter Lab".
![](images/05-1.png)

From the top right, click on "Create JupyterLab Space" button.
![](images/05-2.png)

Provide a name for your Jupyter Lab space and click "Create Space"
![](images/05-3.png)

You will be landing in the page below. Wait for a few seconds to see the "Run space" button enabled.
![](images/05-4.png)

Leave the default values as-is and click "Run space" button.
![](images/05-5.png)

After a couple of minutes, you will see the space created and the "Open Jupyter Lab" button enabled. Click that button which will open a new window.
![](images/05-6.png)

When the widnow is loaded, you'll land in SageMaker Studio.  This is Amazon's hosted notebook environment.

![](images/05-7.png)

## Import from GitHub to SageMaker Studio
For the rest of the labs, we're going to be working with notebooks in SageMaker Studio.  To load them into Studio, we're going to pull them from GitHub using Studio's git integration.

Click on the git icon in the upper left of Studio.  It's below the folder icon on the extreme left of the menu.

Now click "Clone a Repository."

![](images/05-8.png)

In the dialog, enter the address of the git file in the repo we've been working with.  That is:

    https://github.com/neo4j-partners/hands-on-lab-neo4j-and-bedrock.git

Then click "Clone."

This menu is a little finicky.  On my machine, I had to click on the URL after I pasted it and then click the "Clone" button.  If I didn't I receveived an error.

![](images/09.png)

When complete, it will open the README.md for this repo.  In the file explorer on the left, double click on "Lab 5 - Parsing Data."  Click on "parsing-data.ipynb" to open it.

![](images/10.png)

For image, select "Data Science 3.0."  That will populate the kernel and so on.

![](images/11.png)

Click "Select."

![](images/12.png)

You'll see a message that the kernel is starting.  It takes a while.  In my case, it was three minutes to start.  Once complete, you should see this.  Now you're all ready to run through this notebook!

![](images/13.png)

In the next labs, we'll explore further with notebooks.