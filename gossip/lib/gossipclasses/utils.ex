
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
	def add_children(child_class, num_nodes,algorithm, _topology, _adj_list,script_pid, num_nodes_friendly) do
		Enum.each 1..num_nodes, fn(x) ->
        # {:ok, child} = DynamicSupervisor.start_child(Gossipclasses.Supervisor, Gossipclasses.Utils.get_child_spec(Gossipclasses.NodeGossip, x))
        # neighbours = if topology == "full" do
        #   all_nodes = Enum.to_list 1..num_nodes
        #   List.delete(all_nodes, x)
        # else
        #   Map.get(adj_list, x)
		    # end

      if algorithm == "gossip" do
          {:ok, child} = Supervisor.start_child(Gossipclasses.Supervisor, %{:id => x, :start => {child_class, :start_link, [x]}, :restart => :transient,:type => :worker})

            if (x == 1) do
              Gossipclasses.Utils.set_start_child(child)
            end
      else
          # {:ok, child} = DynamicSupervisor.start_child(Gossipclasses.Supervisor, Gossipclasses.Utils.get_child_spec(Gossipclasses.NodeGossip, x))
          {:ok, child} = Supervisor.start_child(Gossipclasses.Supervisor, %{:id => x, :start => {child_class, :start_link, [x]}, :restart => :transient,:type => :worker})
            # IO.inspect(child)
            if (x == 1) do
              Gossipclasses.Utils.set_start_child(child)
            end

      end
	  end
		Supervisor.start_child(Gossipclasses.Supervisor, %{:id => :tracker, :start => {Gossipclasses.NodeTracker, :start_link, [script_pid, num_nodes_friendly]}, :restart => :transient,:type => :worker})
	end

	def set_start_child(pid) do
		:ets.new(:start_child, [:named_table])
    :ets.insert(:start_child, {"start_child_pid", pid})
	end

  def set_id_pid_table(id_pid, pid_to_id, adj_list) do
    :ets.new(:id_pid_mapping, [:named_table, read_concurrency: true])
    :ets.insert(:id_pid_mapping, {"id_pid", id_pid})

    :ets.new(:pid_id_mapping, [:named_table, read_concurrency: true])
    :ets.insert(:pid_id_mapping, {"pid_to_id", pid_to_id})

    :ets.new(:adj_list_table, [:named_table, read_concurrency: true])
    :ets.insert(:adj_list_table, {"adj_list", adj_list})

  end

  def get_pid(id) do
    tup = :ets.lookup(:id_pid_mapping, "id_pid")
		[head| _tail] = tup
    id_pid = elem(head, 1)
    # IO.inspect(id_pid)
    pid = Map.get(id_pid, id)
    pid
  end

	def spread_rumour(algorithm, message \\ nil, s \\ 0, w \\ 0) do
		# TODO: Maybe we should just start the worker with ID 1 because in any topology it should
		# trigger the rumour spreading

		tup = :ets.lookup(:start_child, "start_child_pid")
		[head| _tail] = tup
		starter_pid = elem(head, 1)

		# Logger.debug("Inside getsetgo")
		cond do
			algorithm == "gossip" -> Gossipclasses.NodeGossip.start_rumour(starter_pid, message)
			algorithm == "push-sum" -> Gossipclasses.NodePushSum.receive_message(starter_pid, s, w)
		end
		# {:noreply, 1}
	end
@doc """
Function to set all the neighbours of
"""
  def set_all_neighbours(_algorithm, _num_nodes, adj_list) do

    # Building the id -> PID map
	  sup_children = Supervisor.which_children(Gossipclasses.Supervisor)
    id_pid = Enum.reduce sup_children, %{}, fn x, acc ->
      id = elem(x,0)
      pid = elem(x,1)
      Map.put(acc, id, pid)
    end
    pid_id = Enum.reduce(id_pid, %{}, fn {k, vs}, acc ->
      Map.put(acc,vs,k)
    end)

    Gossipclasses.Utils.set_id_pid_table(id_pid, pid_id, adj_list)

    # map

    # Enum.each  id_pid,  fn {key, val} ->
    #     if !match?({:tracker, _ }, {key,val}) do
    #       cond do

    #         algorithm == "gossip" -> Gossipclasses.NodeGossip.update_id_pid(val, id_pid, pid_id)
    #         algorithm == "push-sum" -> Gossipclasses.NodePushSum.update_id_pid(val, id_pid)
    #       end
    #       # if rem(key,500) == 0 do
    #         # IO.puts("Processed #{key}")
    #       # end
    #     end
    # end
	# IO.inspect(id_pid)

	end

	def log_time(start_time) do
		# Logger.debug("Inside log_time, get start_time")
		# start_time = Gossipclasses.NodeTracker.get_start_time()
		time_now = Time.utc_now()
		time_diff = Time.diff(time_now, start_time, :millisecond)
    IO.puts("Convergence Time #{time_diff}")
 	end

  def updated_num(topology, num_nodes)  do

    num_nodes_temp = if topology == "3dtorus" do
      rows = :math.pow(num_nodes,1/3) |> ceil
      Kernel.trunc(:math.pow(rows, 3))
    else
      temp = num_nodes |> :math.sqrt |> ceil
      Kernel.trunc(:math.pow(temp, 2))
    end
    num_nodes_temp
  end

  def update_num_nodes(topology, num_nodes) do
    num_nodes = cond do
      topology == "3dtorus" -> Gossipclasses.Utils.updated_num(topology, num_nodes)
      topology == "2dgrid" -> Gossipclasses.Utils.updated_num(topology, num_nodes)
      true -> num_nodes
    end
    num_nodes

  end
end
