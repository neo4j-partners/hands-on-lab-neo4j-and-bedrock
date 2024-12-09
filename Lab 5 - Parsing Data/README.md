# Lab 5 - Parsing Data
In this lab we're going to spin up a SageMaker domain.  We'll then use it to run a notebook that calls Neo4j and Amazon Bedrock APIs to load data into Neo4j.

## Create a SageMaker Domain
The first step is to deploy a SageMaker domain.  To do that, open the AWS console [here](https://console.aws.amazon.com/).  In the search bar, type "sagemaker." 

![](images/01.png)

From the search results, click on "Amazon SageMaker AI" under "Services."

![](images/02.png)

A SageMaker Domain is a container for notebooks and other artifacts deployed within SageMaker.  It can be deployed to be shared across an entire data science department.  However, for our uses, we only need a single user.

To that end, click "Set up for single user."

![](images/03.png)

You'll see a message that setup is in progress.

![](images/04.png)

Then you'll be redirected into SageMaker.

![](images/05.png)

Once it finishes, you'll see a message saying "The SageMaker Domain is ready."  Next to the default user, click "Launch" 

![](images/06.png)

Then select "Studio" under that.  You'll be put through a few redirects.

![](images/07.png)

Click on the button with orange background - "JupyterLab".

![](images/08.png)

From the top right, click on "Create JupyterLab Space" button.

![](images/09.png)

Provide a name for your JupyterLab space, perhaps "sec-edgar."

![](images/10.png)

 and click "Create Space"

![](images/11.png)

You will be landing in the page below. Wait for a few seconds to see the "Run space" button enabled.

Click the "Run space" button.

![](images/12.png)

After a couple of minutes, you will see the space created and the "Open JupyterLab" button enabled. Click that button which will open a new window.

![](images/13.png)

When the window is loaded, you'll land in SageMaker Studio.  This is Amazon's hosted notebook environment.

![](images/14.png)

## Import from GitHub to SageMaker Studio
For the rest of the labs, we're going to be working with notebooks in SageMaker Studio.  To load them into Studio, we're going to pull them from GitHub using Studio's git integration.

Click on the git icon in the upper left of Studio.  It's below the folder icon on the extreme left of the menu.

![](images/15.png)

Now click "Clone a Repository."

![](images/16.png)

In the dialog, enter the address of the git file in the repo we've been working with.  That is:

    https://github.com/neo4j-partners/hands-on-lab-neo4j-and-bedrock.git

Then click "Clone."

![](images/17.png)

When complete, it will open the README.md for this repo.  In the file explorer on the left, double click on "Lab 5 - Parsing Data."  

![](images/18.png)

Click on "parsing-data.ipynb" to open it.

![](images/19.png)

Keep the default kernel and click "Select." 

![](images/20.png)

Once complete, you should see this.  Now you're all ready to run through this notebook!  To do so, select a cell and then press the play button.  That runs the cell.  You can now work through the notebook running each cell.

![](images/21.png)

In the next labs, we'll explore further, following this same approach of running through notebooks for each lab.
