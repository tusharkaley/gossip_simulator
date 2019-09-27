defmodule Gossipclasses.Utils do

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

	def get_child_spec(child_class, id) do
		%{
			id: id,
			start: {child_class, :start_link, []},
			restart: :permanent,
			type: :worker,
		}
	end
	def set_start_child(pid) do
		:ets.new(:start_child, [:named_table])
		:ets.insert(:start_child, {"start_child_pid", pid})
	end
	def get_set_go(algorithm) do
		# TODO: Maybe we should just start the worker with ID 1 because in any topology it should
		# trigger the rumour spreading
		test = :ets.lookup(:start_child, "start_child_pid")
		IO.inspect(test)
		# cond do
		# 	algorithm == "gossip" -> "Gossipclasses.NodeGossip"
		# end
	end
end
