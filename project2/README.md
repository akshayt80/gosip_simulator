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
|50	   |703	  |2656	  |880  |773         | 
|100	 |757	  |4595	  |1186	|927         |
|500	 |1221	|13528	|1502	|998         |
|1000	 |4463	|26890	|2060	|1038        |
|1500	 |9413	|44329	|2479	|1223        |

![alt tag](https://github.com/akshayt80/gosip_simulator/blob/master/Gossip.png)

# What is the largest network you managed to deal with for each type of network and the algorithm:



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

