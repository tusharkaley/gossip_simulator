defmodule Gossipclasses.NodeTracker do
	use GenServer
	require Logger
	# Client side
	def start_link(script_pid, num_nodes) do
		Logger.debug("Inside tracker start")
		GenServer.start_link(__MODULE__, [script_pid, num_nodes], [name: :tracker])
	end

	@doc """
	Function to mark the sender as done in the tracker map
	"""
	def mark_as_done(sender) do
		GenServer.cast(:tracker, {:mark_done, sender})
	end

	@doc """
	Function to update the node_store state with the
	key values for all the workers that are online
	"""
	def add_all_to_state do
		GenServer.cast(:tracker, {:update_state})
	end
	@doc """
		Function to get the start time of the protocol.
	"""
	def get_start_time do
		GenServer.call(:tracker, {:tracker_state})
	end

	@impl true
	def init(initial_values) do
		{:ok, script_pid} = Enum.fetch(initial_values, 0)
		{:ok, num_nodes} = Enum.fetch(initial_values, 1)

		node_store = %{"time_start" => Time.utc_now(), "done_count" => 0, "script_pid" => script_pid, "num_nodes" => num_nodes}
		{:ok, node_store}
	end

	@impl true
  	def handle_cast({:update_state}, node_store) do
    	Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_store}" )

		# Get all the children of the supervisor
		sup_children = Supervisor.which_children(Gossipclasses.Supervisor)

		# For each child add an entry in the node_store state
    	node_store_temp = Enum.reduce sup_children, node_store, fn child, acc ->
				pid = elem(child, 1)
        		pid_str = inspect pid
          		Map.put(acc, pid_str, false)
      	end

    	node_store_temp = Map.put(node_store_temp, "time_start", Map.get(node_store, "time_start"))
    	node_store_temp = Map.put(node_store_temp, "done_count", Map.get(node_store, "done_count"))
		node_store = node_store_temp

    	{:noreply, node_store}

	end
	@doc """
	Server side function mark a worker as done
	"""
	@impl true
	def handle_cast({:mark_done, sender}, node_store) do

		sender_str = inspect(sender)
		node_store = Map.put(node_store, sender_str, true)
		node_store = Map.put(node_store, "done_count", node_store["done_count"]+1)
		done_count = Map.get(node_store, "done_count")
		num_nodes = Map.get(node_store, "num_nodes")
		done_percentage = (done_count/num_nodes) * 100

		if done_percentage > 90.0 do
			Logger.log(:warn, "Done %age > 80" )
			terminate_addr = Map.get(node_store, "script_pid")

			send(terminate_addr, {:terminate_now, self()})
		end
		Logger.log(:debug, "PID: #{inspect sender} node state: #{inspect node_store}" )
		{:noreply, node_store}
	end
	@doc """
	Get the start time of when we triggered the algo
	"""
	@impl true
	def handle_call({:tracker_state}, _from, node_store) do
		# Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_store}" )
		{:reply, Map.get(node_store, "time_start"), Map.get(node_store, "time_start")}
	end

end
