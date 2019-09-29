defmodule Proj2.CLI do
  def main(args) do
    [num_nodes, topology, algorithm] = args
    num_nodes = elem(Integer.parse(num_nodes),0)

	# Add children to the supervisor
	Gossipclasses.Utils.add_children(num_nodes)

	# Get the adjancency list based on the topology that was passed in the arguments 
    adj_list = cond do
		topology == "line" -> Gossipclasses.Topologies.line(num_nodes)
		topology == "full" -> Gossipclasses.Topologies.fullNetwork(num_nodes)
		topology == "3dtorus" -> Gossipclasses.Topologies.threeDtorus(num_nodes)
		topology == "2dgrid" -> Gossipclasses.Topologies.random2D(num_nodes)
		topology == "honeycomb" -> Gossipclasses.Topologies.honeycomb(num_nodes)
		topology == "honeycombRandom" -> Gossipclasses.Topologies.randHoneyComb(num_nodes)
    end
    # IO.puts "Printing adj list"
	# IO.inspect(adj_list)

	# Set neighbours of all the nodes based on the adjacency list we just got
    _id_pid = Gossipclasses.Utils.set_all_neighbours(adj_list)

	# Once we have all the nodes set up we update the state of the Node_Tracker
	Gossipclasses.NodeTracker.add_all_to_state()

	# Initiate the rumour spreading process
    Gossipclasses.Utils.spread_rumour(algorithm)

	# We wait on the Node_tracker to tell us to initiate shutdown
    receive do
      {:terminate_now, _pid} -> Gossipclasses.Utils.log_time()
    end
  end

end
