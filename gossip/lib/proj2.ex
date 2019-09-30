defmodule Proj2.CLI do
  def main(args) do
    [num_nodes, topology, algorithm] = args
    num_nodes = elem(Integer.parse(num_nodes),0)

	# Add children to the supervisor

  num_nodes = Kernel.trunc(Gossipclasses.Utils.update_num_nodes(topology, num_nodes))

  adj_list = cond do
    topology == "line" -> Gossipclasses.Topologies.line(num_nodes)
    topology == "full" -> Gossipclasses.Topologies.fullNetwork(num_nodes)
    topology == "3dtorus" -> Gossipclasses.Topologies.threeDtorus(num_nodes)
    topology == "2dgrid" -> Gossipclasses.Topologies.random2D(num_nodes)
    topology == "honeycomb" -> Gossipclasses.Topologies.honeycomb(num_nodes)
    topology == "honeycombRandom" -> Gossipclasses.Topologies.randHoneyComb(num_nodes)
  end

  cond do
    algorithm == "gossip" -> Gossipclasses.Utils.add_children(Gossipclasses.NodeGossip, num_nodes, adj_list, topology)
    algorithm == "push_sum" -> Gossipclasses.Utils.add_children(Gossipclasses.NodePushSum, num_nodes, adj_list, topology)
  end
  Process.sleep(20)
  IO.puts ("Numnodes is #{num_nodes}")
	# Get the adjancency list based on the topology that was passed in the arguments

    # IO.puts "Printing adj list"
  IO.inspect(adj_list)
	IO.puts ("Time #{Time.utc_now()}")
    # # Set neighbours of all the nodes based on the adjacency list we just got
  _id_pid = Gossipclasses.Utils.set_all_neighbours(algorithm)
	IO.puts ("Time #{Time.utc_now()}")
    # # Once we have all the nodes set up we update the state of the Node_Tracker
    # Gossipclasses.NodeTracker.add_all_to_state()

    # Initiate the rumour spreading process
    message = "Bismil ka sandesh hai, 27 ko Lucknow se Lahore jaane waali train, jisme angrezon ka paisa jaata hai, usse hum Kakori mein lootenge... Aur phir unn paison se hathiyar khareedenge."
    s = 0
    w = 0
    cond do
      algorithm == "gossip" -> Gossipclasses.Utils.spread_rumour(algorithm, message)
      algorithm == "push_sum" -> Gossipclasses.Utils.spread_rumour(algorithm, s, w)
    end

    # We wait on the Node_tracker to tell us to initiate shutdown
    receive do
      {:terminate_now, _pid} -> Gossipclasses.Utils.log_time()
    end
    Supervisor.stop(Gossipclasses.Supervisor)
  end

end
