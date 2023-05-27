# Lab 2 - Connect to Neo4j
In this lab, we're going to connect to the Neo4j deployment we created in the previous step.

## Neo4j Browser
A quick thing we can do to check that our deployment is running successfully is to open the Neo4j Browser.  To do so, we're going to need the URI we copied down at the end of our last lab.  Paste that into a web browser and open it.  

In my case, the URI was: http://neo4j-ee-nlb-b36b6b627f78bab6.elb.us-east-1.amazonaws.com:7474/

That should open the Neo4j Browser.

The default database is called "Neo4j."  We can leave that blank.  For a username, enter "neo4j."  For the password, use what we previously chose in the marketplace deployment.  We'd suggested "password" as a password.  Click on "Connect" after entering that information.

![](images/01-neo4jbrowser.png)

You'll be presented with the Neo4j welcome screen at this point.  If you click on the little database icon in the upper left, you can see the contents of our database.

![](images/02-welcome.png)

There's nothing in our database yet.  We can see the nodes, relationships and properties areas are all blank.

![](images/03-contents.png)

Before we move on, let's make sure Neo4j Graph Data Science (GDS) is all set up.  We can do that by entering the following command into the Neo4j Browser:

    RETURN gds.version() as version

Then hit the little blue triangle play button to run it.  You should see the following.

![](images/04-gds.png)

Assuming that all looks good, let's move on...

## Neo4j Bloom
Neo4j Bloom is a business intelligence (BI) tool.  It's running on that same 7474 port that the Neo4j Browser was.  So, to open it up, we can just edit that url slightly by replacing "browser" with "bloom" and hitting enter.  In my case, the URL was "http://neo4j-ee-nlb-b36b6b627f78bab6.elb.us-east-1.amazonaws.com:7474/bloom"

![](images/05-bloom.png)

You can login with the same username and password from before. You need to type the username 'neo4j' (replacing the greyed-out default username)

![](images/06-bloom.png)

That's it.  If you got here, Bloom is installed and running.

## Interacting via Shell - (Optional)
These next steps are really useful if something goes wrong with your Neo4j deployment.  We're going to connect to an instance and check out some logs.  To get the connection information, let's go back to the stack you deployed earlier.  If you closed it, you can simply follow [this link](https://us-east-1.console.aws.amazon.com/cloudformation/home).

Once that's open, click on the "neo4j-ee" stack name.

![](images/07-stacks.png)

Click on "Resources."

![](images/08-stack.png)

Click on the ID of the ASG.  In my case it was "neo4j-ee-Neo4jAutoScalingGroup-ZICK7UZQY61U."

![](images/09-resources.png)

Click on "Instance Management."

![](images/10-asg.png)

If we had deployed a cluster, we would see multiple instances here.  However we only deployed a single node, so we see just one.

Click on the instance ID.  In my case, it was "i-0acc6447f3a48607a."

![](images/11-instancemanagement.png)

Now click "Connect."

![](images/12-instance.png)

In the connect dialog, we have a few options.  We're going to use simplest, the "EC2 Instance Connect."  Simply click on the "Connect" button.  That'll open up a terminal connection in a new window.

Note, that as an alternative to this process, you could SSH to the box using the key you saved earlier.

![](images/13-connect.png)

You should see a terminal like this.

![](images/14-terminal.png)

Now that we have a terminal, let's run a few commands to poke around.  This instance is running vanilla Amazon Linux 2, so looks very much like any other EC2 instance.  After deployment, AWS ran a startup script using cloud-init.  Let's check the log for that to make sure it looks good.  We'll have to sudo as it has restricted permissions.

    sudo su
    cd /var/log/
    cat cloud-init-output.log

Here's what it looks like.

![](images/15-cloudinit.png)

Now let's check out the Neo4j logs using these commands:

    cd /var/log/neo4j
    cat debug.log

That should give us this:

![](images/16-debug.png)

Finally, let's check to make sure the neo4j process is running with this command:

    clear
    ps -aux | grep neo4j

That should give us this:

![](images/17-process.png)

Assuming that all looks good, let's move on...
