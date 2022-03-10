# Lab 2 - Connect to Neo4j
In this lab, we're going to connect to the Neo4j deployment we created in the previous step.

## Neo4j Browser
A quick thing we can do to check that our deployment is running successfully is to open the Neo4j Browser.  To do so, we're going to need to get the public DNS of a node.  To do that, let's go to the AWS Console [here](https://console.aws.amazon.com/).

![](images/01-console.png)

In the search bar, type "cloudformation" and then click on "CloudFormation" under Services.

![](images/02-search.png)

In the results, you should see the deployment we created in the last lab, called "neo4j-ee."  Make sure it says "CREATE_COMPLETE."  Click on that.

![](images/03-stacks.png)

Now we can see the stack we created and detail on it.  Click on the "Resources" tab.  That will allow us to drill down into the resources that the CFT created.

![](images/04-stacks.png)

We can now see all the resources that were created.  We're going to want to drill into the auto scaling group.  Click on that.

![](images/05-resources.png)

Getting closer... Now click on "Instance management" to view individual instances that are part of the ASG.

![](images/06-asg.png)

Under the "Instances" there's "Instance ID."  Hiding under that is the ID of your instance.  In my case, it's "i-0ebfd0056af7f14ad."  Click on that.

![](images/07-instancemanagement.png)

Ok, we're here!  This is the information on our particular instance.  In this case, the Neo4j deployment consists of one instance.  It's possible to deploy clusters as well, in which case we would see multiple instances in this view.

We want the value of "Public IPv4 DNS."  So, click the copy button (two squares on top of each other) next to it.  That will get it into your clipboard.  Now, open a new web browser tab, paste that in and add ":7474" at the end.  7474 is the port that Neo4j Browser uses for HTTP communication.  There's also an HTTPS listener running on 7473.

![](images/08-instance.png)

My URL was "ec2-44-202-197-32.compute-1.amazonaws.com:7474" and after I copied it into Chrome, I hit enter to open it.

![](images/09-url.png)

That should open the Neo4j Browser.

![](images/10-neo4jbrowser.png)

The default database is called "Neo4j."  We can leave that blank.  For a username, enter "neo4j."  For the password, use what we previously chose in the marketplace deployment.  We'd suggested "foo123" as a password.  Click on "Connect" after entering that information.

![](images/11-login.png)

You'll be presented with the Neo4j welcome screen at this point.  If you click on the little database icon in the upper left, you can see the contents of our database.

![](images/12-welcome.png)


There's nothing in our database yet.  We can see the nodes, relationships and properties areas are all blank.

![](images/13-contents.png)

Before we move on, let's make sure Neo4j Graph Data Science (GDS) is all set up.  We can do that by entering the following command into the Neo4j Browser:

    RETURN bloom.version() as version

Then hit the little blue triangle play button to run it.  You should see the following.

![](images/14-gds.png)

Assuming that all looks good, let's move on...

## SSH into an EC2 Instance
First off, let's SSH into 
## Neo4j Bloom
