defmodule Gossipclasses.NodePushSum do
	use GenServer

	def start_link() do
		GenServer.start_link(__MODULE__, [])
	end

	def init(i) do
		node_state = %{"s" =>i , "w" => 1, "ratio" => i, "ratioChange" => 0, "neighbours" => []}
		{:ok, node_state}
	end

	def receive_message(pid, s, w) do
		GenServer.cast(pid, {:receive_message, get_s , get_w} )
	end

	def handle_cast({:receive_message, get_s, get_w}, node_state) do

		s= Map.get node_state "s"
		w= Map.get node_state "s"
		ratio = Map.get node_state "ratio"
		new_s = (s + get_s)/2
		new_w = (w+ get_w)/2
		new_ratio = 
		diff = new_ratio - ratio
		diff = abs(diff)
	
		ratioChange =
		  if(diff < :math.pow(10, -10) && ratioChange == 2) do
			#stop doing stuff
		  else
			next_pid = "7813" #get next enighbour
			GenServer.cast(next_pid, {:next, s_new, w_new})
	
			if(diff < :math.pow(10, -10)) do
				ratioChange + 1
			else
			  0
			end
		  end
		# receive message
		# process it
		# Change self state
		# pass on the message to random neighbour
		sup_children = Supervisor.which_children(Vampirenumbers.Supervisor)
	end
end
