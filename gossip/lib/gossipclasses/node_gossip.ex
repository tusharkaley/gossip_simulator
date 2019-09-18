defmodule Gossipclasses.NodeGossip do
	use GenServer

	@rumour_threshold 10
	def start_link() do
		GenServer.start_link(__MODULE__, rumour_count)
	end

	def init(state) do
		{:ok, state}
	end

	def receive_message(pid) do
		GenServer.cast(pid, {:receive_message})
	end

	def handle_cast({:receive_message}) do
		# Update the rumour count here and make sure to
		# add the terminating condition once the rumour
		# has been heard n number of times
	end
	
end
