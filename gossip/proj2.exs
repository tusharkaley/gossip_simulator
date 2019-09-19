try do
	# Check if we have correct arguments
	if length(System.argv) != 3 do
		raise ArgumentError
	end
	# Pick up the arguments
	[num_nodes, topology, algorithm ] = System.argv
	num_nodes = elem(Integer.parse(num_nodes), 0)
	# if start_num>end_num do
	# 	raise ArgumentError
	# end
	# Vampirenumbers.Boss.divide_range(start_num..end_num)
	# Function call to trigger the network goes here
	# We first need to build the topology based on the given input and then
	# based on the given algo figure out which algo to trigger
	IO.puts("The number of children is #{inspect Supervisor.count_children(Gossipclasses.Supervisor)}")

	DynamicSupervisor.start_child(Gossipclasses.Supervisor, Gossipclasses.Utils.get_child_spec(Gossipclasses.NodeGossip, 1))

	IO.puts("The number of children is #{inspect Supervisor.count_children(Gossipclasses.Supervisor)}")


rescue
	_e in ArgumentError ->  IO.puts "Invalid arguments! Expecting 2 integers with first argument less than the second"
	System.stop(1)
end
