# Lab 1 - Deploy Neo4j
In this lab, we're going to deploy Neo4j Enterprise Edition from the AWS Marketplace.  That listing has a CloudFormation template under it that we'll inspect.  We'll also look at more customizable deployment options.

## Deploy Neo4j Enterprise Edition through the Marketplace
Let's go to AWS Marketplace.  We could go to the Marketplace and search.  But, instead, let's go directly to the AWS Marketplace Seller Profile for Neo4j.  That's [here](https://aws.amazon.com/marketplace/seller-profile?id=23ec694a-d2af-4641-b4d3-b7201ab2f5f9).

On the seller profile page there are two options.  One is for Neo4j AuraDB Enterprise.  Aura is Neo4j's database as a service (DBaaS).  This is a software as a service (SaaS) offering.  The DB means this is the database version of Aura.  On AWS, there's an upcoming AuraDS, which is the data science version of Aura.

Instead of AuraDB Enterprise, we'll be using Neo4j Enterprise Edition.  That is the installable version of Neo4j that runs on Infrastructure as a Service (IaaS).  The AWS listing has a CloudFormation Template (CFT) that deploys Neo4j for you.  This has options to deploy Neo4j Graph Database, Neo4j Graph Data Science and Neo4j Bloom.

* Graph Database is, as the name implies, Neo4j's core database.  It's designed from the ground up to store graphs.  This comes in both a community and an enterprise version.  We're going to use the enterprise version.
* Graph Data Science (GDS) is the graph library that installs on top of the database.  It has implentations of 60 different graph algorithms.  We're going to use GDS to do things like create graph embeddings later in the labs.
* Bloom is a business intelligence tool designed specifically for visualing graphs.  We'll install it as well and use it to explore the data.

So, let's get started deploying...  Click on "Neo4j Enterprise Edition."

![](images/01-sellerprofile.png)

Feel free to poke around the listing.  Once you've read a bit, click "continue to subscribe."

![](images/02-listing.png)

On that page, click "Accept terms."  What you're agreeing to here is a 30 day trial of Neo4j Enterprise Edition.  You can click on the EULA link to read through the terms.

![](images/03-subscribe.png)

After you accept the terms, you see a spinning dialog with a message that it's "pending."  That'll take a few minutes to process.  Underneath the AWS platform is white listing you to deploy the listing.

![](images/04-subscribing.png)

When the subscription is complete, there will be a button to "Continue to Configuration."  Click that.

![](images/05-continue.png)

That takes you to a configuration page.  We can accept the defaults for that.  Check that the region is the same region your VPC and key pair were in.  If it is, click "Continue to Launch."

![](images/06-configure.png)

We now see the launch page. Go to the drop down for "Choose Action" and select "Launch CloudFormation."

![](images/07-launch.png)

With that all set, the "Launch" button should turn yellow.  Click it.

![](images/08-launch.png)

Assuming you're still logged into AWS from our earlier setup, you'll get directed into the AWS console.  This is the CloudFormation service.  CloudFormation is AWS's Infrastructure as Code (IaC) language.  It's analogous to technology like Terraform.  CloudFormation enables you to automate the deployment of AWS resources.

Because we clicked through from Marketplace, the CloudFormation console is already populated with the location of a template in an S3 bucket.  Click "View in Designer."

![](images/09-cft.png)

Now, we're redirected to the CloudFormation designer.  You may need to click the circle icon above the plus zoom to center the view.  From there you can zoom in and explore.

![](images/10-designer.png)

You can see that the template deploys two security groups.  One is external and one is internal.  The internal security group opens connectivity between nodes in the cluster to do things like replication.  The external one allows us to connect to the database from outside the VPC.  This makes it possible for us to navigate to the Neo4j Browser from our laptops.

The CFT creates a role that the CFT uses to setup Neo4j nodes.  It then creates three components of an autoscaling group:
* Launch Configuration
* Instance Template
* Auto Scaling Group

You can click on resources to learn more about them.  You can also view the raw Cloud Formation template.  

![](images/11-designer.png)

It can also be useful to rearrange the resources to better understand how they fit together.

![](images/12-designer.png)

When done, click the back button on your web browser.

Now we're back at the CloudFormation console.  Since we have a good understanding what the template is going to deploy, let's scroll down and click "Next."

![](images/13-stack.png)

It's time to make some choices about how we're deploying Neo4j.

For the stack name, type "neo4j-ee" and move to the next field.  For "Graph Database Version," enter "4.4.9."  For "Install Graph Data Science," check that True is selected.  For "Install Bloom," check that true is selected.

Graph Database Enterprise does not require a license key.  Graph Data Science Enterprise does need a license key.  If you don't specify it, Graph Data Science will start in Community mode.  That means it will not have some features we're going to use later in the lab.  Bloom requires a license key and will not allow you to login without one.  You can use these license keys:

graphDataScienceLicenseKey: 

    eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImJlbkBuZW80ai5jb20iLCJleHAiOjE2NzI1NjAwMDAsImZlYXR1cmVWZXJzaW9uIjoiKiIsIm9yZyI6Ik5lbzRqIFRyYWluaW5nIiwicHViIjoibmVvNGouY29tIiwicXVhbnRpdHkiOiIxIiwicmVnIjoiQmVuIExhY2tleSIsInNjb3BlIjoiUHJvZHVjdGlvbiIsInN1YiI6Im5lbzRqLWdkcyIsInZlciI6IioiLCJpc3MiOiJuZW80ai5jb20iLCJuYmYiOjE2NjQ3Mjc0MDUsImlhdCI6MTY2NDcyNzQwNSwianRpIjoibXI4Vy1RcmVRIn0.FtlakHWD7x2Sn4EmWMwzRnTMsEjsFe9i5JuxlXByfq7WwuGMSbnHxYJK0yCrUfjRkfOkvKsvnEZyQ-H3fxrBZJ1-T0g33LCEWYlfiPY_TOc8qmW1ZbYb4T-dHw8d8RWeNMEAxjwkc7rXBFsnPTvOQqDNY2Fnau7BEwZyKdnLS61e8frhIt2-7abxHHscZcxnXuS6bwybghgetNjeIBYz59rGSN0ovlpmgm00C5egM0F11ntwp5PErWOU-dSTJgmiF_tyO21AHDgGiMpYhUEOM28C4M4gR8a1vpymqRyXCb398teIs6N-CwNygY9ZwW0Aoyj8Ug-Prp-qU29m74fIiA


bloomLicenseKey:

    eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImJlbkBuZW80ai5jb20iLCJleHAiOjE2NzI1NjAwMDAsImZlYXR1cmVWZXJzaW9uIjoiKiIsIm9yZyI6Ik5lbzRqIFRyYWluaW5nIiwicHViIjoibmVvNGouY29tIiwicXVhbnRpdHkiOiIxIiwicmVnIjoiQmVuIExhY2tleSIsInNjb3BlIjoiUHJvZHVjdGlvbiIsInN1YiI6Im5lbzRqLWJsb29tLXNlcnZlciIsInZlciI6IioiLCJpc3MiOiJuZW80ai5jb20iLCJuYmYiOjE2NjQ3MjczNzAsImlhdCI6MTY2NDcyNzM3MCwianRpIjoiekw1SV91RlctIn0.NR6hbGT1bfq96ZuOrFtfo2bEB8m8I6eJ9loS2MZr1XMcAyRQPjS9LxPyyORytiJ8_4EJwBjfHpz2rp18zzQV07I3M1wh7Ozj54HHXDF-jkzBjk2Iv4fenJpRoiVfp6AMUiKR2bTwLJog4o6HuBXI2EI-3enGBT7CTFfb7eGKaEUcmAtxR5AZwROr5EOnnJlZqJ0XsCSPIdoHAqIikEZg-gecHssvlB_ryFCAgdJD9jJQDx4ncBP53tYKGVGP8q1nL3UhpoRgAgIXFYBeKmHZKDGKHbB1sgDiq2j-7RWDIyNoRO_8t3YZ7wtTrHcsmz6HUpJECMfV1gLm_o9_TxSW_w

You need to select a password as well.  This should be six characters or longer.  My go to throw away password is "foo123"

For the "Node Count" select "1." This is the number of Neo4j nodes that will be deployed in the autoscaling group.  Because we're using GDS, we want a single node.  If we were using only GDB, we might deploy in a 3 node cluster for resilience.

Set "Instance type" to "r6i.4xlarge" and ensure disk size is "100."

Finally, for the "SSH CIDR," you need to type "0.0.0.0/0" which is an oddball AWS Marketplace requirement.  If you specify any other value, you're not going to be able to SSH to your Neo4j deployment.

With all that config specified, it's time to click the "Next" button.

![](images/14-details.png)

We can accept all the defaults here.  Click "Next."

![](images/15-details.png)

Now there's one final review page.  Assuming that all looks correct, scroll to the bottom.

Check "I acknowledge that AWS CloudFormation might create IAM resources" as that is, after all, the entire point of a CloudFormation template.  Then click "Create stack."

![](images/16-review.png)

You'll now be redirected to a page where you can see the status of your stacks.  Deployment of this stack seem to take about three minutes.  

![](images/17-deploying.png)

You can hit the refresh button or even click over to "Resources" to see how it's progressing.

![](images/18-deploying.png)

When all done, you'll see "CREATE_COMPLETE" in the stacks menu on the left.

![](images/19-complete.png)

Click on "Outputs."  Copy the URI for the Neo4j Browser.  You're going to need that in the next lab.

Note that once the CloudFormation is complete, a cloud init job on our VMs will kick off once they come up.  That runs asynchronously, so even after CloudFormation reports complete, it may take a few minutes for Neo4j to become available.

![](images/20-outputs.png)

You're now all ready for the next lab where we're going to start using the Neo4j deployment we just created.

## CloudFormation Template
In this lab we worked through deploying via the Marketplace.  The Marketplace is essentially a nice GUI around CloudFormation.  If you're a more technical user and like deploying from the command line there are a variety of options.  These options are also useful if you'd like to modify the CloudFormation template.

The first of these is the Neo4j Partners GitHub organization.  That has a repo with the template from Marketplace as well as additional templates in it.  You can view that [here](https://github.com/neo4j-partners/amazon-cloud-formation-neo4j).

Additionally, Neo4j worked on a Quickstart with Amazon.  That is available [here](https://aws.amazon.com/quickstart/architecture/neo4j-graph-database/), though the code underlying the Quickstart is on GitHub [here](https://github.com/aws-quickstart/quickstart-neo4j/).
