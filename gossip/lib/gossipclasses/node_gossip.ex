defmodule Gossipclasses.NodeGossip do
	use GenServer
	require Logger

	@rumour_threshold 10
	def start_link() do
		GenServer.start_link(__MODULE__, [])
	end

	def init(state) do
		state = 0
		{:ok, state}
	end

	def receive_message(pid) do
		GenServer.cast(pid, {:receive_message})

	end

	def send_message(pid) do
		GenServer.cast(pid, {:send_message})
		Logger.log(:debug, "After the message send")
	end

	def handle_cast({:receive_message}, state) do
		# Update the rumour count here and make sure to
		# add the terminating condition once the rumour
		# has been heard n number of times
		state= state + 1
		target = Gossipclasses.Utils.getTarget(self())
		send_message(target)
		{:noreply, state}
	end

	def handle_cast({:send_message}) do

	end



end
