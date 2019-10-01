defmodule Gossipclasses.NodeGossip do
	use GenServer
	require Logger

	@rumour_threshold 10

	def start_link(id) do
		GenServer.start_link(__MODULE__, [id])
	end

  def init(id) do
    {:ok, id} = Enum.fetch(id, 0)
		# The state of each worker has the following keys
		# message: the actual message that is being passed around
		# head_count: The number of times this worker has heard the message
		# neighbours: list of neighbours of this worker

		node_state = %{"message" => nil, "heard_count" => 0, "id" => id, "id_pid" => nil, "pid_id" => nil}
		{:ok, node_state}
	end
	@doc """
		Client side function to receive message
	"""
	def receive_message(pid, message, sender) do
    GenServer.cast(pid, {:receive_message, message, sender})

	end
  @doc """
  Once you have received the message keep sending it irrespective of you getting a message or not
  """
  def schedule, do: Process.send_after(self(), :psssst, 100)

	@doc """
		Client side function to trigger the rumour spreading
	"""
	def start_rumour(pid, message) do
		GenServer.cast(pid, {:start_rumour, message})
	end

  	def update_id_pid(pid, id_pid, pid_id) do
    # Logger.log(:debug, "Update neighbours: My PID is #{inspect pid} and my node state is #{inspect id_pid}" )
		GenServer.cast(pid, {:add_id_pid, id_pid, pid_id})
	end

	def handle_cast({:receive_message, message, sender}, node_state) do
		# Update the rumour count here and make sure to
		# add the terminating condition once the rumour
		# has been heard n number of times
		node_state= Map.put(node_state, "heard_count", node_state["heard_count"]+1)
    node_state = Map.put(node_state, "message", message)
    heard_count = Map.get(node_state, "heard_count")

    if heard_count == 1 do
      schedule()
    end
    IO.puts("Heard count is #{heard_count}")
		# We flag this actor as done in the Node tracker once it hears the message <runmour_threshold> number of times
		if heard_count == @rumour_threshold do
			# Logger.log(:warn, "PID: #{inspect self()} node state: #{inspect node_state} THRESHOLD REACHED" )
			Gossipclasses.NodeTracker.mark_as_done()
    end

    if heard_count < @rumour_threshold do

      [head| _tail] = :ets.lookup(:adj_list_table, "adj_list")
      adj_list = elem(head, 1)
      neighbours = Map.get(adj_list, Map.get(node_state, "id") )
      [head| _tail] = :ets.lookup(:pid_id_mapping, "pid_to_id")
      pid_id = elem(head, 1)
      sender_id = Map.get(pid_id, sender)
      # IO.puts("Neighbours are #{inspect neighbours} Sender PID: #{inspect sender} id: #{inspect sender_id}")
      neighbours_upd = if length(neighbours) > 1 do
        List.delete(neighbours, sender_id)
        # neighbours
      else
        neighbours
      end
      # Pick a random neighbour from the neighbour list
      # IO.puts("Neighbours are #{inspect neighbours}")
      target = Enum.random(neighbours_upd)
      # This is when the ets table is used
      # target = Gossipclasses.Utils.get_pid(target)
      [head| _tail] = :ets.lookup(:id_pid_mapping, "id_pid")
      id_pid = elem(head, 1)
      target = Map.get(id_pid, target)
		  # Logger.log(:debug, "PID: #{inspect self()} heard count: #{heard_count} sending message to #{inspect target}" )
      Gossipclasses.NodeGossip.receive_message(target, message, self())
    end
		{:noreply, node_state}
	end

	def handle_cast({:add_id_pid, id_pid, pid_id}, node_state) do
    node_state = Map.put(node_state, "id_pid", id_pid)
    node_state = Map.put(node_state, "pid_id", pid_id)
		# Logger.log(:debug, "PID: #{inspect self()} node state: #{inspect node_state}" )
		{:noreply, node_state}
	end

	def handle_cast({:start_rumour, message}, node_state) do

    [head| _tail] = :ets.lookup(:adj_list_table, "adj_list")
    adj_list = elem(head, 1)
    neighbours = Map.get(adj_list, Map.get(node_state, "id") )
    target = Enum.random(neighbours)
    # This is when the ets table is used
    # target = Gossipclasses.Utils.get_pid(target)
    # id_pid = Map.get(node_state, "id_pid")
    [head| _tail] = :ets.lookup(:id_pid_mapping, "id_pid")
    id_pid = elem(head, 1)
    target = Map.get(id_pid, target)
    Gossipclasses.NodeGossip.receive_message(target, message, self())
		{:noreply, node_state}
 	end

  def handle_info(:psssst, node_state) do
    [head| _tail] = :ets.lookup(:adj_list_table, "adj_list")
    adj_list = elem(head, 1)
    neighbours = Map.get(adj_list, Map.get(node_state, "id") )
    message = Map.get(node_state, "message")
    target = Enum.random(neighbours)
    # This is when the ets table is used
    # target = Gossipclasses.Utils.get_pid(target)
    # id_pid = Map.get(node_state, "id_pid")
    [head| _tail] = :ets.lookup(:id_pid_mapping, "id_pid")
    id_pid = elem(head, 1)
    target = Map.get(id_pid, target)
    # Logger.log(:debug, "Scheduled message sending" )
    Gossipclasses.NodeGossip.receive_message(target, message, self())
    schedule()
		{:noreply, node_state}
  end

end
