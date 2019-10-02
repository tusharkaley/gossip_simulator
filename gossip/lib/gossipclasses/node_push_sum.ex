defmodule Gossipclasses.NodePushSum do
	use GenServer
	require Logger

	def start_link(index) do
		GenServer.start_link(__MODULE__, [index])
	end

	def init(state) do
		{:ok,i} = Enum.fetch state,0
		node_state = %{"s" =>i , "w" => 1, "ratioChange" => 0, "neighbours" => nil, "id_pid" => nil, "id" => i}
		{:ok, node_state}
	end

	# def update_neighbours(pid, neighbours) do
	# 	# Logger.log(:debug, "Update neighbours: My PID is #{inspect pid} and my node state is #{inspect neighbours}" )
	# 		GenServer.cast(pid, {:add_neighbours, neighbours})
	# end

	def update_id_pid(pid, id_pid) do
		# Logger.log(:debug, "Update neighbours: My PID is #{inspect pid} and my node state is #{inspect id_pid}" )
		GenServer.cast(pid, {:add_id_pid, id_pid})
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
		ratioChange = Map.get node_state,"ratioChange"

		ratioChange =
		cond do
			ratioChange>2 -> ratioChange
		  (diff < :math.pow(10, -10) && ratioChange == 2) ->
		  		# Logger.log(:warn, "PID: #{inspect self()} node state: #{inspect node_state} RATIO REACHED" )
		  		Gossipclasses.NodeTracker.mark_as_done()

		  		ratioChange
		  diff < :math.pow(10, -10)-> ratioChange + 1
		  true -> 0
		  end
      # neighbours = Map.get(node_state, "neighbours")
      [head| _tail] = :ets.lookup(:adj_list_table, "adj_list")
      adj_list = elem(head, 1)
      neighbours = Map.get(adj_list, Map.get(node_state, "id") )
			# Pick a random neighbour from the neighbour list
			target = Enum.random(neighbours)
			[head| _tail] = :ets.lookup(:id_pid_mapping, "id_pid")
      id_pid = elem(head, 1)
			target = Map.get(id_pid, target)
			# Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_state} sending values to #{inspect target}" )
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

	def handle_cast({:add_id_pid, id_pid}, node_state) do
		node_state = Map.put(node_state, "id_pid", id_pid)
		# Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_state}" )
		{:noreply, node_state}
	end

	def handle_cast(:start_pushing, node_state) do
    # neighbours = Map.get(node_state, "neighbours")
    [head| _tail] = :ets.lookup(:adj_list_table, "adj_list")
    adj_list = elem(head, 1)
    neighbours = Map.get(adj_list, Map.get(node_state, "id") )
		target = Enum.random(neighbours)
    # id_pid = Map.get(node_state, "id_pid")
    [head| _tail] = :ets.lookup(:id_pid_mapping, "id_pid")
    id_pid = elem(head, 1)
		target = Map.get(id_pid, target)
		s= Map.get(node_state, "s")
		w= Map.get(node_state, "w")
		Gossipclasses.NodePushSum.receive_message(target, s, w)
		{:reply, node_state}
	end

end
