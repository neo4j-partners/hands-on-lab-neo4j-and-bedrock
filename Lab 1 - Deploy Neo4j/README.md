# Lab 1 - Deploy Neo4j
In this lab, we're going to deploy Neo4j Enterprise Edition from the AWS Marketplace.  That listing has a Cloud Formation template under it that we'll inspect.  We'll also look at more customizable deployment options.

## Pick a Region
For this lab, you'll want to pick one AWS region to put all your resources in.  It doesn't particularly matter which region you use.  You can tell which region is selected by looking in the upper right of the AWS console [here](https://console.aws.amazon.com/).  In the image below, the region is Ohio, also known as us-east-2.

![](images/01-region.png)

Whatever region you select, make sure that you're logged into it as you proceed through the following steps.

## Create a Key Pair
The machine we're going to create for the lab will be an EC2 instance.  We'll need to create a key pair to connect to the instance.

If you don't have a key pair already, follow through these steps.  First, navigate to the console [here](https://console.aws.amazon.com/).  Now, type "key pairs" in the search bar at the top of the console.  

![](images/02-console.png)

Click on the "Key pairs" result that shows up under "Features."

![](images/03-search.png)

In this window, you'll see a list of any existing key pairs.  Unless you have an old key pair that you want to use, you should click "Create key pair" in the upper right.

![](images/04-keypairs.png)

This menu is for creating the key pair.  For a name, type neo4j-sagemaker.  All the other defaults will work.  So, accept those and click "Create key pair."

![](images/05-create.png)

That leads us back to our list of key pairs.  You can see the newly created key paid.  In my case, I'm using Chrome on a mac.  The private key was automatically downloaded to my ~/Downloads folder.  You can see it in the lower left of the browser.

In order to connect to the instance later, we'll need the private key in the path for our SSH client.

![](images/06-created.png)

On a mac you can open a terminal and run these commands to move the key and then set the permissions:

    mv -f ~/Downloads/neo4j-sagemaker.pem ~/.ssh/
    chmod 400 ~/.ssh/neo4j-sagemaker.pem

![](images/07-terminal.png)

That's it!

## Configure VPC
AWS accounts are created with a default VPC.  We're going to be using that for this deployment.  Sometimes people delete the default VPCs in their accounts.  Let's check and make sure the default VPC exists and is properly configured.  To do that, open an AWS console [here](https://console.aws.amazon.com/).

Type "VPC" in the search bar.

![](images/08-console.png)

Select "VPC" under services.

![](images/09-search.png)

In the VPC menu, select "VPCs."  That will give us a view of our VPCs.  With any luck, you'll already have at least one.

[](images/10-vpc.png)

Now scroll to the right of the VPC. 

![](images/11-vpc.png)

Check if you have have VPC with the value "Yes" under "Default VPC."  

![](images/12-default.png)

If you don't have a default VPC, you're going to need to create one.  Click "Create VPC" in the upper right.  If you do have a default VPC, then we should check a few more things.  Click on the default VPC.

In that view, check "DNS hostnames" is enabled and that "DNS resolution" is enabled.

![](images/13-vpc.png)

Finally, click "Subnets" in the menu on the left of the console.

![](images/14-subnets.png)

Scroll to the right and locate the subnets in your default VPC.  Those are the ones that say "Yes" under "Default subnet."  Make sure that "Auto-assign public IPv4 address" is "Yes."

![](images/15-defaultsubnet.png)

## Deploy Neo4j Enterprise Edition through the Marketplace
Alright, we've checked a bunch of prerequisities are ok.  Now, we're all read to deploy Neo4j!  To do so, let's go to AWS Marketplace.  We could go to the Marketplace and search.  But, instead, let's go directly to the AWS Marketplace Seller Profile for Neo4j.  That's [here](https://aws.amazon.com/marketplace/seller-profile?id=23ec694a-d2af-4641-b4d3-b7201ab2f5f9).

On the seller profile page there are two options.  One is for Neo4j AuraDB Enterprise.  Aura is Neo4j's database as a service (DBaaS).  This is a software as a service (SaaS) offering.  The DB means this is the database version of Aura.  On AWS, there's an upcoming AuraDS, which is the data science version of Aura.

Instead of AuraDB Enterprise, we'll be using Neo4j Enterprise Edition.  That is the installable version of Neo4j that runs on Infrastructure as a Service (IaaS).  The AWS listing has a Cloud Formation Template (CFT) that deploys Neo4j for you.  This has options to deploy Neo4j Graph Database, Neo4j Graph Data Science and Neo4j Bloom.

* Graph Database is, as the name implies, Neo4j's core database.  It's designed from the ground up to store graphs.  This comes in both a community and an enterprise version.  We're going to use the enterprise version.
* Graph Data Science (GDS) is the graph library that installs on top of the database.  It has implentations of 60 different graph algorithms.  We're going to use GDS to do things like create graph embeddings later in the labs.
* Bloom is a business intelligence tool designed specifically for visualing graphs.  We'll install it as well and use it to explore the data.

So, let's get started deploying...  Click on "Neo4j Enterprise Edition."

![](images/16-sellerprofile.png)

Feel free to poke around the listing.  Once you've read a bit, click "continue to subscribe."

![](images/17-listing.png)

On that page, click "Accept terms."  What you're agreeing to here is a 30 day trial of Neo4j Enterprise Edition.  You can click on the EULA link to read through the terms.

![](images/18-subscribe.png)

After you accept the terms, you see a spinning dialog with a message that it's "pending."  That'll take a few minutes to process.  Underneath the AWS platform is white listing you to deploy the listing.

![](images/19-subscribing.png)

When the subscription is complete, there will be a button to "Continue to Configuration."  Click that.

![](images/20-continue.png)

That takes you to a configuration page.  We can accept the defaults for that.  Check that the region is the same region your VPC and key pair were in.  If it is, click "Continue to Launch."

![](images/21-configure.png)

We now see the launch page. Go to the drop down for "Choose Action" and select "Launch CloudFormation."

![](images/22-launch.png)

With that all set, the "Launch" button should turn yellow.  Click it.

![](images/23-launch.png)

Assuming you're still logged into AWS from our earlier setup, you'll get directed into the AWS console.  This is the CloudFormation service.  CloudFormation is AWS's Infrastructure as Code (IaC) language.  It's analogous to technology like Terraform.  CloudFormation enables you to automate the deployment of AWS resources.

Make certain that you're in the same region that your key pair and VPC from earlier are in.  If not, change the region using the menu in the upper right.

Because we clicked through from Marketplace, the CloudFormation conssole is already populated with the location of a template in an s3 bucket.  Click "View in Designer."

![](images/24-cft.png)

This directs us into the CloudFormation designer.  

You can see that the template deploys two security groups.  One is external and one is internal.  The internal security group opens connectivity between nodes in the cluster to do things like replication.  The external one allows us to connect to the database from outside the VPC.  This makes it possible for us to navigate to the Neo4j Browser from our laptops.

The CFT creates a role that the CFT uses to setup Neo4j nodes.  It then creates three components of an autoscaling group:
* Launch Configuration
* Instance Template
* Auto Scaling Group

You can click on resources to learn more about them.  You can also view the raw Cloud Formation template.  When done, click the back button on your web browser.

![](images/25-designer.png)

Now we're back at the CloudFormation console.  Since we have a good understanding what the template is going to deploy, let's scroll down and click "Next."

![](images/26-stack.png)

We're now at the stage where we need to make some choices about how we're deploying Neo4j.

For the stack name, type "neo4j-ee" and move to the next field.  For "Graph Database Version," enter 4.4.8.  For "Install Graph Data Science," check that True is selected.

For "Install Bloom," check that true is selected.

Graph Database Enterprise does not require a license key.  Graph Data Science Enterprise does need a license key.  If you don't specify it, Graph Data Science will start in Community mode.  That means it will not have some features we're going to use later in the lab.  Bloom requires a license key and will not start unless you specify one.  You can use these license keys:

* graphDataScienceLicenseKey: eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImJlbkBuZW80ai5jb20iLCJleHAiOjE2NjIwMTU2MDAsImZlYXR1cmVWZXJzaW9uIjoiKiIsIm9yZyI6Ik5lbzRqIFRyYWluaW5nIiwicHViIjoibmVvNGouY29tIiwicXVhbnRpdHkiOiIxIiwicmVnIjoiQmVuIExhY2tleSIsInNjb3BlIjoiVHJpYWwiLCJzdWIiOiJuZW80ai1nZHMiLCJ2ZXIiOiIqIiwiaXNzIjoibmVvNGouY29tIiwibmJmIjoxNjU1ODU5ODk0LCJpYXQiOjE2NTU4NTk4OTQsImp0aSI6IjlEUXBBY0o4ZiJ9.ec4o61vr161T4l9hjPVZIuc5Ax0FBxADgEzzVIty0kheNKwzJCrsHluyksxZ2KRAi5O_M1nc5sVXMLU6kVXOY0eTqNpnxLQHHFCiW4EVwDHf_2QqWYImEs8B8A0iR636gkoL5Nf3L2ygWGUwkWlP-2gvLuDc_KrF5iCwqK3Cnhjfrxf_WleaIEs4MVOS7iLqjwFRBRzAEHNz6SrJX8MGISIId4izn34sSitOr1O7EIVabRnJ2ULIl95JORbxj4pTgBezrhDrasCDzWBPAyQy10qKRb2b2WbNJfQOB4wJ53iVZ0v2wqlzKIgOSnCFBb_XymvJBhnmr1xpsyeh2uxrYA
* bloomLicenseKey: eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImJlbkBuZW80ai5jb20iLCJleHAiOjE2NjIwMTU2MDAsImZlYXR1cmVWZXJzaW9uIjoiKiIsIm9yZyI6Ik5lbzRqIFRyYWluaW5nIiwicHViIjoibmVvNGouY29tIiwicXVhbnRpdHkiOiIxIiwicmVnIjoiQmVuIExhY2tleSIsInNjb3BlIjoiVHJpYWwiLCJzdWIiOiJuZW80ai1ibG9vbS1zZXJ2ZXIiLCJ2ZXIiOiIqIiwiaXNzIjoibmVvNGouY29tIiwibmJmIjoxNjU1ODU5ODU5LCJpYXQiOjE2NTU4NTk4NTksImp0aSI6IjlZMDk2T21ocCJ9.pRgAj-gL-ycx1GNCvZcCCvIv3xS7vLmq6bLxkD20gGLSnI_NP7Eg5f0nYHGhIHz1lBHJ9caPitAlqTkh3cmcAaBZvrsmKcG6MHWwaFuC8W1p30LmnyrQL7JqlbGUFOg_PB0Hkrac7Q5_Zog0la3X0o00zxQ7BG_GpusGp5W-xqrQQ9tTxjY3bKnEeQyxbSqLVL6yTzfcb9sQbvGt8NFT1kGzXsxEMKYkXmqTt5SNQjQEszdc2IIrMMHEFaUl5RVjwqUbsPFBIAEzGXgdIPHYQ1CrZIuE4wmIy_PrirmjReqqQ97t88uheli3CLjah2vSZHhe7uR7FLy3e5tGH2afPg

You need to select a password as well.  This should be six characters or longer.  My go to throw away password is "foo123"

For the "Node Count" select "1." This is the number of Neo4j nodes that will be deployed in the autoscaling group.  Because we're using GDS, we want a single node.  If we were using only GDB, we might deploy in a 3 node cluster for resilience.

Set "Instance type" to "t3.xlarge" and ensure disk size is "100."

For "Key Name," you'll want to select the key pair you created earlier, called "neo4j-sagemaker."

Finally, for the "SSH CIDR," you need to type "0.0.0.0/0" which is an oddball AWS Marketplace requirement.  If you specify any other value, you're not going to be able to SSH to your Neo4j deployment.

With all that config specified, it's time to click the "Next" button.

![](images/27-details.png)

We can accept all the defaults here.  Click "Next."

![](images/28-details.png)

Now there's one final review page.  Assuming that all looks correct, scroll to the bottom.

Check "I acknowledge that AWS CloudFormation might create IAM resources" as that is, after all, the entire point of a Cloud Formation template.  Then click "Create stack."

![](images/29-review.png)

You'll now be redirected to a page where you can see the status of your stacks.  Deployment of this stack seem to take about three minutes.  

![](images/30-deploying.png)

You can hit the refresh button or even click over to "Resources" to see how it's progressing.

![](images/31-deploying.png)

When all done, you'll see "CREATE_COMPLETE" in the stacks menu on the left.

![](images/32-complete.png)

Once the Cloud Formation is complete, a cloud init job on our VMs will kick off once they come up.  That runs asynchronously, so even after Cloud Formation reports complete, it may take a few minutes for Neo4j to become available.

You're now all ready for the next lab where we're going to start using the Neo4j deployment we just created.

## Cloud Formation Template
In this lab we worked through deploying via the Marketplace.  The Marketplace is essentially a nice GUI around Cloud Formation.  If you're a more technical user and like deploying from the command line there are a variety of options.  These options are also useful if you'd like to modify the Cloud Formation template.

The first of these is the Neo4j Partners GitHub organization.  That has a repo with the template from Marketplace as well as additional templates in it.  You can view that [here](https://github.com/neo4j-partners/amazon-cloud-formation-neo4j).

Additionally, Neo4j worked on a Quickstart with Amazon.  That is available [here](https://aws.amazon.com/quickstart/architecture/neo4j-graph-database/), though the code underlying the Quickstart is on GitHub [here](https://github.com/aws-quickstart/quickstart-neo4j/).
