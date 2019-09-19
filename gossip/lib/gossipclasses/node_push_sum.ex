defmodule Gossipclasses.NodePushSum do
	use GenServer

	def start_link() do
		GenServer.start_link(__MODULE__, [])
	end

	def init(state) do
		{:ok, %{s: 0, w: 0}}
	end

	def receive_message(pid, s, w) do
		GenServer.cast(pid, {:receive_message, s , w} )
	end

	def handle_cast({:receive_message, s , w}, state) do
		# receive message
		# process it
		# Change self state
		# pass on the message to random neighbour
		sup_children = Supervisor.which_children(Vampirenumbers.Supervisor)
	end
end
