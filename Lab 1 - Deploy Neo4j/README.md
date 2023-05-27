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

![](images/01-sellerprofile-v2.png)

Feel free to poke around the listing.  Once you've read a bit, click "continue to subscribe."

![](images/02-listing.png)

On that page, click "Accept terms."  What you're agreeing to here is a 30 day trial of Neo4j Enterprise Edition.  You can click on the EULA link to read through the terms.

![](images/03-subscribe.png)

After you accept the terms, you see a spinning dialog with a message that it's "pending."  That'll take a few minutes to process.  Underneath the AWS platform is white listing you to deploy the listing.

![](images/04-subscribing.png)

When the subscription is complete, there will be a button to "Continue to Configuration."  Click that.

![](images/05-continue.png)

That takes you to a configuration page.  We can accept the defaults for that.  Check that the region is the same region your VPC and key pair were in.  If it is, click "Continue to Launch."

![](images/06-configure-v2.png)

We now see the launch page. Go to the drop down for "Choose Action" and select "Launch CloudFormation" and the "Launch" button should turn yellow.  Click it.

![](images/08-launch-v2.png)

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

For the stack name, type "neo4j-ee" and move to the next field. For "Install Graph Data Science," check that True is selected.  For "Install Bloom," check that true is selected.

Graph Database Enterprise does not require a license key.  Graph Data Science Enterprise does need a license key.  If you don't specify it, Graph Data Science will start in Community mode.  That means it will not have some features we're going to use later in the lab.  Bloom requires a license key and will not allow you to login without one. 

> **Warning**
> Replace 'None' with the below keys.

You can use these trial license keys:

Graph Data Science License Key: 

    eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Imd1aGFuLnNpdmFqaUBuZW80ai5jb20iLCJleHAiOjE2ODc2NjU2MDAsImZlYXR1cmVWZXJzaW9uIjoiKiIsIm9yZyI6Ik5lbzRqIChQYXJ0bmVyKSIsInB1YiI6Im5lbzRqLmNvbSIsInF1YW50aXR5IjoiMSIsInJlZyI6Ikd1aGFuIFNpdmFqaSIsInNjb3BlIjoiVHJpYWwiLCJzdWIiOiJuZW80ai1nZHMiLCJ2ZXIiOiIqIiwiaXNzIjoibmVvNGouY29tIiwibmJmIjoxNjg1MTM4MTYxLCJpYXQiOjE2ODUxMzgxNjEsImp0aSI6IlpMeUl6MHl4WCJ9.RQ4BytsOb6fRD-TlK9HRlKWGDY-FTa2BI0_0QClwkBugXnIPIezGa6F6s9OVO4xQfw7PiTMS0Q4SMYxQ8o_fwgbh1MKlOqj2EHqcBiHb8hh-PE8QzSiUtdHNIyduCIQAUJa3_0ie_5eqOg3Cj7IaiQkXw8UDSgygqzCm0CeKDdrbtVAUyOt2hLZAmVl6uaAuXdHCb0nGlLZENjgti514lPRU36eKPuXOPDfBhNfQUgYYJ5-h_YsJvpbv87v9RfV-XosGcG1Ln1gfAc2eFmyU6qQtKqD8w4jAuCud0edBcZsxvH4-os81vtGyNwJAjDAtfCI500jcwTAq6d7uCfubvg


Bloom License Key:

    eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Imd1aGFuLnNpdmFqaUBuZW80ai5jb20iLCJleHAiOjE2ODc2NjU2MDAsImZlYXR1cmVWZXJzaW9uIjoiKiIsIm9yZyI6Ik5lbzRqIChQYXJ0bmVyKSIsInB1YiI6Im5lbzRqLmNvbSIsInF1YW50aXR5IjoiMSIsInJlZyI6Ikd1aGFuIFNpdmFqaSIsInNjb3BlIjoiVHJpYWwiLCJzdWIiOiJuZW80ai1ibG9vbS1zZXJ2ZXIiLCJ2ZXIiOiIqIiwiaXNzIjoibmVvNGouY29tIiwibmJmIjoxNjg1MTM4MTg4LCJpYXQiOjE2ODUxMzgxODgsImp0aSI6InlSQW83eDFkViJ9.kiThjWScxmWPWPhdZsmR7TI2lC-51fJg23t5JkcfDDSh7ywwW0nr9nhzSY1ZuWQe7Lbh9p1Ry_I4hrItzrWqkjdEqAXVQhparBFlMdjButUzU5rSfjyXjaELnmhVlPCl1Wz9B4p3w3VIEmBJHoDZWYpBq72VAnRWZm_J_L_N7wPmoguvDyivrvE5grGftXutAV6Ip9plwNsoIMf7Xu-ZI-YA9bOXC_M-xmoAttgUMwQWmS_D5ZPR0dGVEQHv48DeH3En8hAcypMAfA5OtAEB-5-vKFKeLb8VAd39kXIUlSTxr2af4st8N7UuQ-zPHtiPYyI9kKEc2aQ2nZh-VJRHXg

![](images/14-details-v3.png)

You need to select a password as well.  This should be eight characters or longer.  My go to throw away password is "password"

For the "Node Count" select 1. This is the number of Neo4j nodes that will be deployed in the autoscaling group.  Because we're using GDS, we want a single node.  If we were using only GDB, we might deploy in a 3 node cluster for resilience.

Set "Instance type" to "r6i.4xlarge" and ensure disk size is "100."

Finally, for the "SSH CIDR," you need to type "0.0.0.0/0" which is an oddball AWS Marketplace requirement.  If you specify any other value, you're not going to be able to SSH to your Neo4j deployment.

With all that config specified, it's time to click the "Next" button.

We can accept all the defaults here.  Click "Next."

![](images/15-details.png)

Now there's one final review page.  Assuming that all looks correct, scroll to the bottom.

Check "I acknowledge that AWS CloudFormation might create IAM resources" as that is, after all, the entire point of a CloudFormation template.  Then click "Submit"

![](images/16-review.png)

You'll now be redirected to a page where you can see the status of your stacks.  Deployment of this stack seem to take about three minutes.  

![](images/17-deploying.png)

You can hit the refresh button or even click over to "Resources" to see how it's progressing.

If you see an error on the cloud deployment, please delete this stack and restart this Lab 1 and select a different region, (as shown in the 'Configure this software' section above.)

![](images/18-deploying.png)

When all done, you'll see "CREATE_COMPLETE" in the stacks menu on the left.

![](images/19-complete.png)

Click on "Outputs."  Copy the URI for the Neo4j Browser.  You're going to need that in the next lab.

Note that once the CloudFormation is complete, a cloud init job on our VMs will kick off once they come up.  That runs asynchronously, so even after CloudFormation reports complete, it may take a few minutes for Neo4j to become available.

![](images/20-outputs-v2.png)

You're now all ready for the next lab where we're going to start using the Neo4j deployment we just created.

## CloudFormation Template
In this lab we worked through deploying via the Marketplace.  The Marketplace is essentially a nice GUI around CloudFormation.  If you're a more technical user and like deploying from the command line there are a variety of options.  These options are also useful if you'd like to modify the CloudFormation template.

The first of these is the Neo4j Partners GitHub organization.  That has a repo with the template from Marketplace as well as additional templates in it.  You can view that [here](https://github.com/neo4j-partners/amazon-cloud-formation-neo4j).

Additionally, Neo4j worked on a Quickstart with Amazon.  That is available [here](https://aws.amazon.com/quickstart/architecture/neo4j-graph-database/), though the code underlying the Quickstart is on GitHub [here](https://github.com/aws-quickstart/quickstart-neo4j/).
