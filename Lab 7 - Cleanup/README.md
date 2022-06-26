# Lab 7 - Cleanup
We deployed a lot of resources in these labs.  Clearly, you want to make sure they don't run up a bill from unused AWS resources.  In this section we'll work through deleting themm, starting with most expensive first.

## The Nuclear Option
If you really want to stop AWS billing, close your AWS account.  In the rest of the lab, we'll walk through less drastic options that allow you to continue to experiment and play with AWS.  But, if you'd like to just be done, follow the instructions [here](https://aws.amazon.com/premiumsupport/knowledge-center/close-aws-account/).

## Delete the Neo4j Deployment
By far the most expensive thing we deployed was our Neo4j Marketplace listings.  That includes a t3.xlarge which dominates our costs.  That costs $0.1670/hour or $120/month.  The deployment also has an EBS gp3 volume and a few other things for which the cost is more negligable.

WARNING -- if you go to AWS EC2 and delete your VM this will not delete the deployment.  The ASG that is part of the stack will automatically spin up a new VM.  This is great for resilience but important to understand when taking apart your IaaS deployment.

We can go ahead and delete it, even if your SageMaker job is still running.  You've already exported the data from Neo4j to S3, so deleting it won't impact that job.

At any rate, to delete it, log into the AWS console [here](https://console.aws.amazon.com/).  Click on "CloudFormation" in the "Recently visited" menu.

![](images/01-console.png)

Select the radio button by our "neo4j-ee" stack.

![](images/02-stack.png)

Click the "Delete" button.

![](images/03-stack.png)

Click "Delete stack" to confirm.

![](images/04-stack.png)

The delete is now in progress.  That should take less that five minutes to complete.  You can click the refresh icon to update status.

![](images/05-inprogress.png)

When complete you'll see this.

![](images/06-complete.png)

Great!  You've now deleted your deployment!

## Delete SageMaker
Our SageMaker deployment likely fits in the free tier, so you are unlikely to incur any cost from it.  Nonetheless, we can step through the steps to delete the domain and underlying resources.

## Delete S3 Bucket
The last set of resources that have any potential charges associated with them is the s3 bucket underlying our SageMaker deployment.  The [S3 free tier is up to 5GB](https://aws.amazon.com/pm/serv-s3), so it's unlikely you've run over that.

Nonetheless, we can login to the console and delete any data in S3 from there.  To do so, open the s3 service [here](https://s3.console.aws.amazon.com/s3/buckets).  From there, select and delete any S3 buckets you have.  Note, if they have contents, you'll be forced to first delete those contents before you can delete the bucket.
