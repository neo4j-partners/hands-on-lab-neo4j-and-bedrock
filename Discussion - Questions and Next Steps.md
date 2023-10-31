# Discussion - Questions and Next Steps
This section has some thoughts on future work, improvements and next steps.  Please feel free to [PR](https://github.com/neo4j-partners/hands-on-lab-neo4j-and-sagemaker/pulls) your ideas and suggestions.

## Lab 0 - Sign In
In previous versions of the lab we had users sign up for a new AWS account they owned.  That was kinda cool in that attendees got to see everything start from scratch.  However, the signup required a credit card number and a phone number for identity verification.  It was also a fair bit of work.  Now we're using [OneBlink.AI](https://oneblink.ai/) to provision.  We'd be curious to hear how your experience was with this approach.

Other approaches, such as AWS Event Engine provide a way to access AWS.  However, the result is different from what a user experiences in a real environment.  The goal of this lab was to give you hands on end to end experience.  Given that, this seems to be the best way available.

## Lab 1 - Deploy Neo4j
We deployed an IaaS listing for Neo4j.  That uses a CFT which has a variety of prerequisites.  Neo4j is currently working on a click to deploy version of our managed service for AWS, Aura.  Once that is available, we'll probably transition this lab content to that service, simplifying setup.

## Lab 2 - Connect to Neo4j
We connected over HTTP.  We are working on improving the self signed cert experience for deployment on IaaS.  We'd also like to use Let's Encrypt or something similar to get a proper cert.  Using Aura avoids this issue entirely.

## Lab 3 - Moving Data
We used LOAD CSV to pull data in.  That is one of many ways.  Neo4j Data Importer is another.  You may have noticed the tab for that in Aura.  We're exploring incorporating it into this lab.

We're also working with AWS on Glue integration.  

The Neo4j [Spark Connector](https://neo4j.com/docs/spark/current/) is another way to get data in.  We've been working on a demo of that with EMR.

## Lab 4 - Exploring Data
This section of the lab could be greatly expanded.

## Lab 5 - Parsing Data
We only parse 3 files here.  That's down to very limited quotas.  With more, we could make a bunch of parallel calls.  It'd be neat to get to that point and parse all the data that way rather than with LOAD CSV.

## Lab 6 - Chatbot
The chatbot is somewhat brittle.  More work could be done to improve it.  You can almost certainly think up some questions that it should answer but can't.  That's part of what is so exciting about this space -- everything is developing quickly.

## Lab 7 - Sematic Search
The free trial we're using has very limited quotas.  That forced us to throttle.  The result is that one cell takes 10-15 minutes to run.  We need to cut the data set down to work around that.  Ultimately the quotas will probably go up.

## Next Steps
We hope you enjoyed these labs.  If you have any questions, feel free to reach out directly to any of us.  We'd love the opportunity to explore and support your use cases with your data.
