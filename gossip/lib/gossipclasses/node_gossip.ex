defmodule Gossipclasses.NodeGossip do
	use GenServer
	require Logger

	@rumour_threshold 10

	def start_link() do
		GenServer.start_link(__MODULE__, [])
	end

	def init(_state) do
		# The state of each worker has the following keys
		# message: the actual message that is being passed around
		# head_count: The number of times this worker has heard the message
		# neighbours: list of neighbours of this worker
		# TODO: function to update the neighbours key of the worker

		node_state = %{"message" => nil, "heard_count" => 0, "neighbours" => []}
		{:ok, node_state}
	end

	def receive_message(pid, message) do
		GenServer.cast(pid, {:receive_message, message})

	end

	def update_neighbours(pid, neighbours) do
		GenServer.cast(pid, {:add_neighbours, neighbours})
	end

	def handle_cast({:receive_message, message}, node_state) do
		# Update the rumour count here and make sure to
		# add the terminating condition once the rumour
		# has been heard n number of times
		node_state= Map.put(node_state, "heard_count", node_state["heard_count"]+1)

		node_state= Map.put(node_state, "message", message)
		if node_state["heard_count"]>@rumour_threshold do
			Gossipclasses.NodeTracker.mark_as_done(self())
		else
			target = GossipClasses.Utils.getTarget(self())
			Gossipclasses.NodeGossip.receive_message(target, message)
		end

		{:noreply, node_state}
	end

	def handle_cast({:add_neighbours, neighbours}, node_state) do
		node_state = Map.put(node_state, "neighbiours", neighbours)
		{:noreply, node_state}
	end



end
