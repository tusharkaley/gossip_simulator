
defmodule Gossipclasses.Utils do
	require Logger
    def getChildren do

    end

    def getTarget(caller_pid) do
    	sup_children = Supervisor.which_children(Gossipclasses.Supervisor)

		target_pid = Enum.each(sup_children, fn(child) ->
				pid = elem(child, 1)
				target_p = if (caller_pid != pid) do
							pid
						end
				target_p
				end)
			target_pid
		end
	@doc """
		Function to get the child Spec for the workers
	"""
	def get_child_spec(child_class, id) do

    	child_spec = %{
			            :id => id,
			            :start => {child_class, :start_link, []},
						:restart => :transient,
						:type => :worker
        }
        # %{:id => id, :start => {child_class, :start_link, []}, :restart => :transient,:type => :worker}
		child_spec

	end

	def set_start_child(pid) do
		:ets.new(:start_child, [:named_table])
		:ets.insert(:start_child, {"start_child_pid", pid})
	end

	def get_set_go(algorithm, s \\ 0, w \\ 0) do
		# TODO: Maybe we should just start the worker with ID 1 because in any topology it should
		# trigger the rumour spreading

		tup = :ets.lookup(:start_child, "start_child_pid")
		[head| _tail] = tup
		starter_pid = elem(head, 1)
		IO.inspect(starter_pid)
		message = "Bismil ka sandesh hai, 27 ko Lucknow se Lahore jaane waali train, jisme angrezon ka paisa jaata hai, usse hum Kakori mein lootenge... Aur phir unn paison se hathiyar khareedenge."
		Logger.debug("Inside getsetgo")
		cond do
			algorithm == "gossip" -> Gossipclasses.NodeGossip.start_rumour(starter_pid, message)
			algorithm == "push_sum" -> Gossipclasses.NodePushSum.receive_message(starter_pid, s, w)
		end
		# {:noreply, 1}
	end
@doc """
Function to set all the neighbours of
"""
  def set_all_neighbours(adj_list) do

	sup_children = Supervisor.which_children(Gossipclasses.Supervisor)
    id_pid = Enum.reduce sup_children, %{}, fn x, acc ->
		id = elem(x,0)
		pid = elem(x,1)
		Map.put(acc, id, pid)
    end
    # map
	# test = Enum.map([1,2,4], fn(x) -> Map.get(id_pid, x) end)
	Enum.each  adj_list,  fn {key, val} ->
			neighbours = Enum.map(val, fn(x) -> Map.get(id_pid, x) end)
			# IO.inspect(test)
			Gossipclasses.NodeGossip.update_neighbours(Map.get(id_pid, key), neighbours)
			# IO.puts "#{k} --> #{v}"
	end
	IO.inspect(id_pid)
	end

	def log_time do
		start_time = Gossipclasses.NodeTracker.get_start_time()
		time_now = Time.utc_now()
		time_diff = Time.diff(time_now, start_time, :millisecond)
		Logger.debug("The time difference is #{time_diff}")
	end
end
