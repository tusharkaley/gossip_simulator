defmodule Gossipclasses.NodeTracker do
	use GenServer
	require Logger
	# Client side
	def start_link do
		GenServer.start_link(__MODULE__, [], [name: :tracker])
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

	@impl true
	def init(_node_store) do
		node_store = %{"time_start" => Time.utc_now(), "done_count" => 0}
		{:ok, node_store}
	end

	@impl true
	def handle_cast({:update_state}, node_store) do
		# Get all the children of the supervisor
		sup_children = Supervisor.which_children(Gossipclasses.Supervisor)
		# For each child add an entry in the node_store state
		Enum.each(sup_children, fn (child) ->
			if !match?({:tracker, _,_,_}, child) do
				pid = elem(child, 1)
				pid_str = inspect pid
				node_store = Map.put(node_store, pid_str, false)
			end
		end)
		{:noreply, node_store}
	end
	@doc """
	Server side function mark a worker as done
	"""
	def handle_cast({:mark_done, sender}, node_store) do

		sender_str = inspect(sender)
		node_store = Map.put(node_store, sender_str, true)
		node_store = Map.put(node_store, "done_count", node_store["done_count"]+1)
		{:no_reply, node_store}
	end

end
