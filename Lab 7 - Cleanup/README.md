# Lab 7 - Cleanup
We deployed a lot of resources in these labs.  Clearly, you want to make sure they don't run up a bill from unused AWS resources.  In this section we'll work through deleting themm, starting with most expensive first.

## Delete the Neo4j Deployment
By far the most expensive thing we deployed was our Neo4j Marketplace listings.  That includes a r6i.4xlarge which dominates our costs.  That costs $1.01/hour or $727.20/month.  The deployment also has an EBS gp3 volume and a few other things for which the cost is more negligable.

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

## The Nuclear Option
If you really want to stop AWS billing, close your AWS account.  If you've already stopped your active VM, you could close your account to make very sure no additional charges are incurred.  Alternatively, in the rest of the lab, we'll walk through less drastic options that allow you to continue to experiment and play with AWS.  But, if you prefer the nuclear approach, follow the instructions [here](https://aws.amazon.com/premiumsupport/knowledge-center/close-aws-account/).

## Delete SageMaker
Our SageMaker deployment likely fits in the free tier, so you are unlikely to incur any cost from it.  The major cost from it comes from running training jobs, but if you aren't doing that, it's just a little storage, etc.  Nonetheless, we can step through the steps to delete the domain and underlying resources.

To delete it, log into the AWS console [here](https://console.aws.amazon.com/).  Click on "SageMaker" in the "Recently visited" menu.

![](images/07-console.png)

Click on "Studio."

![](images/08-sagemaker.png)

Click "Launch SageMaker Studio." and open Domain.

![](images/09-studio-v2.png)

Everything we did in SageMaker is contained within our domain.  However, we can't delete it without first deleting the users within it.  To do that, we need to delete the applications within it.

Click on the domain and your user under "Users."

![](images/10-studio-v2.png)

Click "Delete App" to delete your kernel gateway.

Click "Yes, delete app," type "delete" and click "Delete."

![](images/12-confirm.png)

Under the default app, expand the action and Click "Delete."

That begins deleting the application.

![](images/16-deleting.png)

The screen will not refresh automatically.  If you refresh it manually, you'll see your application deleted.

When that's complete, click "Edit" in the bottom right.

![](images/17-deleted.png)

Now click "Delete user."

![](images/18-edit.png)

Click "Yes, delete user."  Type "delete."  Then click "Delete."

![](images/19-delete.png)

Now the user is deleting.  Refresh the screen.

Once the user is deleted.  Click on "Domain" to navigate to the domain.

Click the "Edit" button after selecting your domain.

![](images/21-domain-edit.png)

Now click "Delete domain."

![](images/23-domain.png)

Click "Yes, delete my Domain."  Then type "delete."  Then click "Delete."

![](images/24-delete.png)

The domain is now deleting.

![](images/25-deleting-v2.png)

When all deleted you will see this menu.

![](images/26-deleted-v2.png)

## Delete S3 Bucket
The last set of resources that have any potential charges associated with them is the s3 bucket underlying our SageMaker deployment.  The [S3 free tier is up to 5GB](https://aws.amazon.com/pm/serv-s3), so it's unlikely you've run over that.

Nonetheless, we can login to the console and delete any data in S3 from there.  To do so, open the S3 service [here](https://s3.console.aws.amazon.com/s3/buckets).  From there, select and delete any S3 buckets you have.  Note, if they have contents, you'll be forced to first delete those contents before you can delete the bucket.

## Miscellaneous
We also created an IAM role.  That's free but you can delete it in the console to avoid clutter.
