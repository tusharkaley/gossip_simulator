defmodule GossipTrigger do
  use Application
    def start(_type, _args) do
        {:ok, _pid} = Gossipclasses.Supervisor.start_link()
    end
end
