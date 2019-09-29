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

		node_state = %{"message" => nil, "heard_count" => 0, "neighbours" => []}
		{:ok, node_state}
	end
	@doc """
		Client side function to receive message
	"""
	def receive_message(pid, message) do
		GenServer.cast(pid, {:receive_message, message})

	end

	@doc """
		Client side function to trigger the rumour spreading
	"""
	def start_rumour(pid, message) do
		GenServer.call(pid, {:start_rumour, message}, :infinity)
	end

  	def update_neighbours(pid, neighbours) do
    # Logger.log(:debug, "Update neighbours: My PID is #{inspect pid} and my node state is #{inspect neighbours}" )
		GenServer.cast(pid, {:add_neighbours, neighbours})
	end

	def handle_cast({:receive_message, message}, node_state) do
		# Update the rumour count here and make sure to
		# add the terminating condition once the rumour
		# has been heard n number of times
		node_state= Map.put(node_state, "heard_count", node_state["heard_count"]+1)
    	node_state = Map.put(node_state, "message", message)
		heard_count = Map.get(node_state, "heard_count")

		# We flag this actor as done in the Node tracker once it hears the message <runmour_threshold> number of times
		if heard_count == @rumour_threshold do
			Logger.log(:warn, "PID: #{inspect self()} node state: #{inspect node_state} THRESHOLD REACHED" )
			Gossipclasses.NodeTracker.mark_as_done(self())
		end
		neighbours = Map.get(node_state, "neighbours")
		# Pick a random neighbour from the neighbour list
		target = Enum.random(neighbours)
		Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_state} sending message to #{inspect target}" )
		Gossipclasses.NodeGossip.receive_message(target, message)
		{:noreply, node_state}
	end

	def handle_cast({:add_neighbours, neighbours}, node_state) do
		node_state = Map.put(node_state, "neighbours", neighbours)
		Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_state}" )
		{:noreply, node_state}
	end

	def handle_call({:start_rumour, message}, _from, node_state) do
		neighbours = Map.get(node_state, "neighbours")
		target = Enum.random(neighbours)
		Gossipclasses.NodeGossip.receive_message(target, message)
		{:reply, node_state, node_state}
	end
end
