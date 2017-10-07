# Project2

READ ME file for Distributed Operating Systems - Project 2, Due Date: 7th October,2017

Group members:

Team 3
1. Anmol Khanna, UFID:65140549, anmolkhanna93@ufl.edu,
2. Akshay Singh Jetawat, UFID:22163183, akshayt80@ufl.edu,

# What is Working:

Gossip Protocol: Each process in the network listens for gossips. When a rumor is heard by a process, it spreads it to other neighbor process in the network selected at random. The alignment of neighbor varies according to the underlying topology. 
Each process in the topology maintains its own state which comprises of its neighbors, a count variable to store the number of rumors received so far i.e. every process has a count of how many times it has heard a rumor.Once a process receives a particular number of rumors, it sends the notification to its parents notifying about its completion and terminates.

We experimented with different number of nodes with different topologies keeping the count of rumors to be constant in all the cases for the termination of a process. The time taken to achieve convergence (in ms) for different configurations is shown below:

|Nodes |Full	|line	  |2d	  |Imperfect 2d|
|------|------|-------|-----|------------|
|50	   |2219	|10656	|3823 |3823        |
|100	 |2225	|15682	|4427	|3420        |
|500	 |2586	|67340	|7443	|4426        |
|1000	 |3266	|113572	|8852	|4830        |
|1500	 |4072	|289448	|10863|5233        |

![alt tag](https://github.com/akshayt80/gosip_simulator/blob/master/Gossip.png)

PushSum Algorithm:
The Actor initiates the algorithm by sending a message to one of its randomly selected neighboring processes. Each process maintains its own state to hold the process id's of its neighboring processes. This state depends upon the topology being used. We use s to represent the sum, w to store the weight and use the process id's of the parent process for notifying once the process is completed. In the input of the message, the s and w values of the received message are added to the initial s and w values of the process. Also, the total sum of all the process is constant. With every iteration of the process, the values of s and w keep on changing. The process is termintaed as follows, the receiver process calculates the difference between the s/w values and when the valus of the change goes below the threshold times, the process is terminated. Afte all the processes get terminated, the parent process gives the total time for the protocol and terminates.

We experimented with different number of nodes with different topologies keeping the count of rumors to be constant in all the cases for the termination of a process. The time taken to achieve convergence (in ms) for different configurations is shown below:

#Largest Network Managed for each algorithm and topology:

For Gossip:
full: 4000


|Nodes |Full	|line	  |2d	  |Imperfect 2d|
|------|------|-------|-----|------------|
|50	   |703	  |2656	  |880  |773         | 
|100	 |757	  |4595	  |1186	|927         |
|500	 |1221	|13528	|1502	|998         |
|1000	 |4463	|26890	|2060	|1038        |
|1500	 |9413	|44329	|2479	|1223        |

TODO: Update the table below for PushSum and make a graph
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `project2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:project2, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/project2](https://hexdocs.pm/project2).

