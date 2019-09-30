
# THIS FILE WON'T BE USED  NOW SINCE WE HAVE THE EXECUTABLE IN PLACE

try do
	# Check if we have correct arguments
	if length(System.argv) != 3 do
		raise ArgumentError
	end
	# Pick up the arguments
	[num_nodes, topology, algorithm ] = System.argv
	num_nodes = elem(Integer.parse(num_nodes), 0)


	# We first need to build the topology based on the given input and then
	# based on the given algo figure out which algo to trigger
	IO.puts("The number of children is #{inspect Supervisor.count_children(Gossipclasses.Supervisor)}")
	# Call to helper function to add the given number of workers to the Dynamic Supervisor

	Enum.each(1..num_nodes, fn(x) ->
		# {:ok, child} = DynamicSupervisor.start_child(Gossipclasses.Supervisor, Gossipclasses.Utils.get_child_spec(Gossipclasses.NodeGossip, x))
		{:ok, child} = Supervisor.start_child(Gossipclasses.Supervisor, %{:id => x, :start => {Gossipclasses.NodeGossip, :start_link, []}, :restart => :transient,:type => :worker})
			IO.inspect(child)
			if (x == 1) do
				Gossipclasses.Utils.set_start_child(child)
			end
		end
	)
  	Supervisor.start_child(Gossipclasses.Supervisor, %{:id => :tracker, :start => {Gossipclasses.NodeTracker, :start_link, [self(), num_nodes]}, :restart => :transient,:type => :worker})

	# Build topologies here
	# TODO: figure out if we want to get a map in return and post process it to set neighbours of the actors
	# or do it directly from the call to the topology function

	adj_list = cond do
					topology == "line" -> Gossipclasses.Topologies.line(num_nodes)
					topology == "full" -> Gossipclasses.Topologies.fullNetwork(num_nodes)
					topology == "3Dtorus" -> Gossipclasses.Topologies.threeDtorus(num_nodes)
					topology == "2dgrid" -> Gossipclasses.Topologies.random2D(num_nodes)
					topology == "honeycomb" -> Gossipclasses.Topologies.honeycomb(num_nodes)
					topology == "randhoneycomb" -> Gossipclasses.Topologies.randHoneyComb(num_nodes)
				end

	IO.puts "Printing adj list"
	IO.inspect(adj_list)
    id_pid = Gossipclasses.Utils.set_all_neighbours(adj_list)
    # IO.inspect(id_pid)
	# Once the topology is in place we trigger the algorithm from here
	# Maybe we'll have to call the set neighbours call for all the actors
	#  assuming we have an adjacency list in place
	Gossipclasses.NodeTracker.add_all_to_state()
	Gossipclasses.Utils.get_set_go(algorithm)
    # # Process.sleep(3000)

	# IO.puts("Reached the end The number of children is #{inspect Supervisor.count_children(Gossipclasses.Supervisor)}")
	# IO.puts("My PID #{inspect self()}")
	receive do
		{:terminate_now, pid} -> Gossipclasses.Utils.log_time()
	end

rescue
	e in ArgumentError ->  e
	System.stop(1)
end
