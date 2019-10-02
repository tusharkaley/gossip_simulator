#These are the building blocks of this project:

- Gossipclasses.Supervisor: Supervisor
- Gossipclasses.NodeGossip: Genserver module which handles the case where the algorithm chosen is GOSSIP
- Gossipclasses.NodePushSum: Genserver module which handles the case where the algorithm chosen is PUSH-SUM
- Gossipclasses.NodeTracker: This is like the BOSS module which keeps track of the number of nodes that mark themselves as done in case of  either of the algorithms and eventually takes care of shutting down the system

proj2.ex: This is the module which accepts user arguments and can be used to trigger everything.

This accepts following arguments 
- Number of nodes
- Topology
- Algorithm

We get a map representing the adjacency list based on the number of nodes of the form->
%{
    1 => [2],
    2 => [1,3],
    3 => [2]
}

Then we add the children to the supervisor based on the number of nodes entered and the correction factor that was applied if the topology was 2dgrid or 3dtorus.

With the adjacency list and the id to pid mapping that we can get now that we have added the children to the supervisor we add these to ets tables

Now that we have setup everything we initiate the rumour spreading

Exit condition:
Based on the algorithm and their respective exit strategies the tracker marks the node as done when the exit condition is met and the node no longer sends messages when it receives any messages

In case of gossip we have implemented an additional functionality of sending the message to a random neighbour every 200 milliseconds.

Shutdown:
Once 90% of the nodes are marked as done by the tracker we trigger shutdown
