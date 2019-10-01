defmodule Gossipclasses.NodePushSum do
	use GenServer
	require Logger

	def start_link(index) do
		GenServer.start_link(__MODULE__, [index])
	end

	def init(index) do
		{:ok,i} = Enum.fetch index,0
		node_state = %{"s" =>i , "w" => 1, "ratioChange" => 0, "neighbours" => []}
		{:ok, node_state}
	end

	def update_neighbours(pid, neighbours) do
		# Logger.log(:debug, "Update neighbours: My PID is #{inspect pid} and my node state is #{inspect neighbours}" )
			GenServer.cast(pid, {:add_neighbours, neighbours})
	end

	def start_pushing(pid, message) do
		GenServer.call(pid, {:start_pushing, message}, :infinity)
	end

	def receive_message(pid, s, w) do
		GenServer.cast(pid, {:receive_message, s , w} )
	end

	def handle_cast({:receive_message, get_s, get_w}, node_state) do

		s= Map.get node_state, "s"
		w= Map.get node_state, "w"
		ratio = s/w
		new_s = (s+ get_s)/2
		new_w = (w+ get_w)/2
		new_ratio = new_s/new_w
		diff = new_ratio - ratio
		ratioChange= Map.get node_state,"ratioChange"

		ratioChange =
		cond do
		  (diff < :math.pow(10, -10) && ratioChange == 2) ->
		  		Logger.log(:warn, "PID: #{inspect self()} node state: #{inspect node_state} RATIO REACHED" )
		  		Gossipclasses.NodeTracker.mark_as_done()
		  		ratioChange
		  diff < :math.pow(10, -10)-> ratioChange + 1
		  true -> 0
		  end
			neighbours = Map.get(node_state, "neighbours")
			# Pick a random neighbour from the neighbour list
			target = Enum.random(neighbours)
			Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_state} sending values to #{inspect target}" )
			Gossipclasses.NodePushSum.receive_message(target, new_s, new_w)

		node_state= Map.put(node_state, "s", new_s)
		node_state= Map.put(node_state, "w", new_w)
		node_state= Map.put(node_state, "ratioChange", ratioChange)

		# if ratioChange >2 do
		# 	#mark as done
		# 	Logger.log(:warn, "PID: #{inspect self()} node state: #{inspect node_state} RATIO REACHED" )
		# 	Gossipclasses.NodeTracker.mark_as_done(self())
		# else
		# neighbours = Map.get(node_state, "neighbours")
		# # Pick a random neighbour from the neighbour list
		# target = Enum.random(neighbours)
		# Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_state} sending values to #{inspect target}" )
		# Gossipclasses.NodePushSum.receive_message(target, new_s,new_w)
		# end
		# receive message
		# process it
		# Change self state
		# pass on the message to random neighbour
		{:noreply, node_state}
	end

	def handle_cast({:add_neighbours, neighbours}, node_state) do
		node_state = Map.put(node_state, "neighbours", neighbours)
		Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_state}" )
		{:noreply, node_state}
	end

	def handle_call(:start_pushing,_from, node_state) do
		neighbours = Map.get(node_state, "neighbours")
		target = Enum.random(neighbours)
		s= Map.get(node_state, "s")
		w= Map.get(node_state, "w")
		Gossipclasses.NodePushSum.receive_message(target, s, w)
		{:reply, node_state, node_state}
	end

end
