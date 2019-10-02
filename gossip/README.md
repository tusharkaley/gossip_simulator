# Gossip

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gossip` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gossip, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/gossip](https://hexdocs.pm/gossip).


# How to run:


Navigate to the gossip_simulator/gossip

Run 
mix escript.build

For Mac: ./proj2 <num nodes> <topology> <algorithm>

For Windows: escript proj2 <num nodes> <topology> <algorithm>

Possible values for topology:
- line
- full
- 3Dtorus
- rand2D
- honeycomb
- randhoneycomb

Possible values for algorithm:
- gossip
- push-sum

Sample run:

./proj2 100 line gossip
./proj2 100 full gossip
./proj2 100 3Dtorus gossip
./proj2 100 rand2D gossip
./proj2 100 honeycomb gossip
./proj2 100 randhoneycomb gossip


./proj2 100 line push-sum
./proj2 100 full push-sum
./proj2 100 3Dtorus push-sum
./proj2 100 rand2D push-sum
./proj2 100 honeycomb push-sum
./proj2 100 randhoneycomb push-sum

Sample output:
./proj2 1000 randhoneycomb push-sum

Getting the Adjacency list
Adding children to the Supervisor
Populating ETS tables
Initiate the rumour spreading
Done with 300 nodes
Done with 600 nodes
Done with 900 nodes
Convergence Time 1048

Please note:
We print a log for every 200 nodes being marked as done.