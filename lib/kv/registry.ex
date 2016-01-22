defmodule KV.Registry do
  use GenServer


  ## Client API


  @doc """
  Starts the registry.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc """
  Looks up the bucket pid for name stored in server
  Returns {:ok, pid} if the bucket exists, :error otherwise
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated to a given name in server
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
    #GenServer.call(server, {:create, name})
  end

  @doc """
  Stops the registry
  """
  def stop(server) do
    GenServer.stop(server)
  end


  ## Server Callbacks


  def init(:ok) do
    #{:ok, %{}}
    names = %{}
    refs = %{}

    {:ok, {names, refs}}
  end

  # call: synchronous with response
  #def handle_call({:lookup, name}, _from, names) do
  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  # cast: asynchronous, without response
  #def handle_cast({:create, name}, names) do
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      #{:noreply, names}
      {:noreply, {names, refs}}
    else
      #{:ok, bucket} = KV.Bucket.start_link()
      #{:noreply, Map.put(names, name, bucket)}
      {:ok, pid} = KV.Bucket.Supervisor.start_bucket() #.start_link()
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      {:noreply, {names, refs}}
    end
    # case lookup(names, name) do
    #   {:ok, pid} ->
    #     {:reply, pid, {names, refs}}
    #   :error ->
    #     {:ok, pid} = KV.Bucket.Supervisor.start_bucket()
    #     ref = Process.monitor(pid)
    #     refs = Map.put(refs, ref, name)
    #     names = Map.put(names, name, pid)
    #     {:repls, pid, {names, refs}}
    # end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    # catch-all clause
    {:noreply, state}
  end
end
