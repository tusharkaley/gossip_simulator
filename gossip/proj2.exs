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
		{:ok, child} = DynamicSupervisor.start_child(Gossipclasses.Supervisor, Gossipclasses.Utils.get_child_spec(Gossipclasses.NodeGossip, x))
		IO.inspect(child)
		if (x == 1) do
			Gossipclasses.Utils.set_start_child(child)
		end
	end
	)
	# Build topologies here
	# TODO: figure out if we want to get a map in return and post process it to set neighbours of the actors
	# or do it directly from the call to the topology function

	adj_matrix = cond do
					topology == "line" -> "call to Gossipclasses.Topologies.line()"
					topology == "full" -> "Gossipclasses.Topologies.full()"
					topology == "3dtorus" -> "Gossipclasses.Topologies.3dtorus()"
					topology == "2dgrid" -> "Gossipclasses.Topologies.2dgrid()"
					topology == "honeycomb" -> "Gossipclasses.Topologies.honeycomb()"
					topology == "honeycombRandom" -> "Gossipclasses.Topologies.honeycombRandom()"

				end
	# Once the topology is in place we trigger the algorithm from here
	Gossipclasses.Utils.get_set_go(algorithm)

	IO.puts("The number of children is #{inspect Supervisor.count_children(Gossipclasses.Supervisor)}")


rescue
	_e in ArgumentError ->  IO.puts "Invalid arguments! Expecting 2 integers with first argument less than the second"
	System.stop(1)
end
