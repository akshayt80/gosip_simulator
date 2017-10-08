# Project2Bonus

- We have made our code to work for two types of faliures.
1. Permanent node failures
2. Permanent connection failures

- We are getting the percentage of nodes to be failed in the network as command line and using that to kill connections or nodes

- We have implemented the failure model for both push-sum and gossip.

-execution command: 
mix escript.build
1. ./project2 20 full push-sum 5 node
2. ./project2 20 full push-sum 5 connection

Gossip
|Nodes |Full   |2d     |Imperfect 2d|
|------|-------|-------|------------|
|20    |2243   |2830   |2822        |
|40    |2255   |3030   |3025        |
|60    |2290   |3228   |3026        |
|80    |2461   |3832   |3224        |
|100   |2585   |3838   |3421        |

Observations:
1. Fault does not effect the rate of convergence much. The implemented algorithms are highly fault tolerant.
2. As the network grows it gets difficult for the algorithm to converge.
3. Line topolofy is not fault tolerant as when any node dies the network colapses. So, we have not implemented the fault checking in Line topology.

