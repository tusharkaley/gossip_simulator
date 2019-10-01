defmodule Proj2.CLI do
  def main(args) do
    [num_nodes, topology, algorithm] = args
    num_nodes = elem(Integer.parse(num_nodes),0)

	# Add children to the supervisor
  setup_start = Time.utc_now()

  num_nodes = Kernel.trunc(Gossipclasses.Utils.update_num_nodes(topology, num_nodes))
  # IO.puts ("Numnodes is #{num_nodes}")
  # Get the adjancency list based on the topology that was passed in the arguments

  # IO.puts("Getting the Adjacency list")
  adj_list = cond do
    topology == "line" -> Gossipclasses.Topologies.line(num_nodes)
    topology == "full" -> Gossipclasses.Topologies.fullNetwork(num_nodes)
    topology == "3dtorus" -> Gossipclasses.Topologies.threeDtorus(num_nodes)
    topology == "2dgrid" -> Gossipclasses.Topologies.random2D(num_nodes)
    topology == "honeycomb" -> Gossipclasses.Topologies.honeycomb(num_nodes)
    topology == "honeycombRandom" -> Gossipclasses.Topologies.randHoneyComb(num_nodes)
  end
  # num_nodes_empty = Enum.count(adj_list, fn (key) -> length(Map.get(adj_list, key)) > 0  end)
  # Enum.reduce([1, 2, 3], 0, fn x, acc -> x + acc end)
  # IO.inspect(adj_list)
  num_nodes_friendly = Enum.reduce(adj_list, 0, fn x, acc ->

    if length(elem(x, 1)) > 0 do
      1 + acc
    else
      acc
    end
  end)
  IO.puts("Num_nodes_non_empty #{num_nodes_friendly}")
  # IO.puts("Adding children to the Supervisor")
  cond do
    algorithm == "gossip" -> Gossipclasses.Utils.add_children(Gossipclasses.NodeGossip, num_nodes,algorithm,topology, adj_list,self(), num_nodes_friendly)
    algorithm == "push-sum" -> Gossipclasses.Utils.add_children(Gossipclasses.NodePushSum, num_nodes,algorithm,topology, adj_list,self(), num_nodes_friendly)
  end



  # IO.inspect("Time start #{inspect Time.utc_now()}")
  # IO.inspect(adj_list)
    # # Set neighbours of all the nodes based on the adjacency list we just got
  _id_pid = Gossipclasses.Utils.set_all_neighbours(algorithm, num_nodes, adj_list)
  # IO.inspect("Time end #{inspect Time.utc_now()}")
    # # Once we have all the nodes set up we update the state of the Node_Tracker
    # Gossipclasses.NodeTracker.add_all_to_state()

    # Initiate the rumour spreading process
    message = "Gossip"
    s = 0
    w = 0
    # IO.puts("Initiate the rumour spreading")
    cond do
      algorithm == "gossip" -> Gossipclasses.Utils.spread_rumour(algorithm, message)
      algorithm == "push-sum" -> Gossipclasses.Utils.spread_rumour(algorithm, s, w)
    end
    start_time = Time.utc_now()
    # IO.puts("Time setup end #{start_time}")
    time_diff = Time.diff(start_time, setup_start, :millisecond)
    IO.puts("Setup time #{time_diff}")
    # We wait on the Node_tracker to tell us to initiate shutdown
    receive do
      {:terminate_now, _pid} -> Gossipclasses.Utils.log_time(start_time)
    end
    Supervisor.stop(Gossipclasses.Supervisor)
  end

end
