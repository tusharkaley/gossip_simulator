
defmodule Gossipclasses.Supervisor do
	use DynamicSupervisor

	require Logger
@moduledoc """
This is the Supervisor for the Vampire Numbers project
"""
		@doc """
		Client function which triggers the Supervisor start
		"""
		def start_link() do
			DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
		end

		def init(_nums_range) do
			# nums_range = Enum.to_list nums_range
			# children = Gossipclasses.Utils.get_children()
			# children = [worker(Vampirenumbers.Boss, [], [id: :boss, restart: :transient, shutdown: :infinity]) | children]
			# IO.inspect children
			# loop(children_pids)
			# supervise(children, strategy: :one_for_one)
			DynamicSupervisor.init(strategy: :one_for_one)

		end

		def start_worker do
			# Code to start the actors goes here
		end
end
