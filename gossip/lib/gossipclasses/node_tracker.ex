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
	def mark_as_done() do
		GenServer.cast(:tracker, {:mark_done})
	end

	@doc """
		Function to get the start time of the protocol.
	"""
	def get_start_time() do
		Logger.log(:debug, "PID_IN_TRACKER_STATE: get_start_time")
		GenServer.call(:tracker, {:tracker_state})
	end

	@impl true
	def init(initial_values) do
		{:ok, script_pid} = Enum.fetch(initial_values, 0)
		{:ok, num_nodes} = Enum.fetch(initial_values, 1)
		node_store = %{"time_start" => Time.utc_now(), "done_count" => 0, "script_pid" => script_pid, "num_nodes" => num_nodes}
		{:ok, node_store}
	end

	@doc """
	Server side function mark a worker as done
	"""
	@impl true

	def handle_cast({:mark_done}, node_store) do

		# _sender_str = inspect(sender)
    # node_store = Map.put(node_store, sender_str, true)
    # IO.puts("Mark as done entry")
		node_store = Map.put(node_store, "done_count", node_store["done_count"]+1)
		done_count = Map.get(node_store, "done_count")
		num_nodes = Map.get(node_store, "num_nodes")
		done_percentage = (done_count/num_nodes) * 100
		# IO.puts("Done count is #{done_count}")
		if done_percentage > 90.0 do
			Logger.log(:warn, "We are about to shut down #{inspect node_store}")
			terminate_addr = Map.get(node_store, "script_pid")
			Logger.log(:warn, "terminate_addr is as follows: #{inspect terminate_addr}")
			send(terminate_addr, {:terminate_now, self()})
		end
		# Logger.log(:debug, "node state: #{inspect node_store}" )
		{:noreply, node_store}
	end
	@doc """
	Get the start time of when we triggered the algo
	"""
	@impl true
	def handle_call({:tracker_state}, _from, node_store) do
		Logger.log(:debug, "PID_IN_TRACKER_STATE: #{inspect self()} node state: #{inspect node_store}" )
		{:reply, Map.get(node_store, "time_start"), Map.get(node_store, "time_start")}
	end

end
