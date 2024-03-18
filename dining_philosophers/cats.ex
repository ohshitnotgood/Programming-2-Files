defmodule Cat do
  def meow(cat, _, _, _, 0, _, _, _) do
    "#{cat} is done eating" |> IO.inspect()
  end

  def meow(cat, kernelProcess, c1, c2, food, base_hunger, hunger, laziness) do
    # request chopsticks
    "sent request" |> I_O.print(cat)
    send(kernelProcess, {:request, cat, hunger, c1, c2, self()})

    # thread-blocking
    receive do
      :denied ->
        "denied, hunger now #{hunger}" |> I_O.print(cat)
        meow(cat, kernelProcess, c1, c2, food, base_hunger, hunger - 1, laziness)

      {:approved, c1, c2} ->
        "approved, food now #{food - 1}" |> I_O.print(cat)
        "beginning eating" |> I_O.print(cat)
        :timer.sleep(1)
        "ended eating, returning chopsticks" |> I_O.print(cat)

        send(kernelProcess, {:return, c1, c2})

        "start thinking" |> I_O.print(cat)
        :timer.sleep(laziness)
        "end thinking" |> I_O.print(cat)
        meow(cat, kernelProcess, c1, c2, food - 1,  base_hunger, base_hunger, laziness)
    end
  end
end

defmodule Katnel do
  def run(requestMap, availabilityMap) do
    receive do
      {:request, cat, hunger, c1, c2, cattoPid} ->
        "request from #{cat}" |> I_O.print_kernel(cat)
        requestMap = handleRequests(requestMap, cat, hunger, c1, c2, cattoPid)
        "kernel   added to queue, now requests are " |> IO.write()
        requestMap |> IO.inspect()
        availabilityMap |> IO.inspect()
        serveRequest(requestMap, availabilityMap)

      {:return, c1, c2} ->
        "return for #{c1} and #{c2}" |> I_O.print_kernel("N/A")
        a = handleReturns(availabilityMap, c1, c2)
        "kernel   return handled, chopsticks are now " |> IO.write()
        a |> IO.inspect()
        serveRequest(requestMap, a)
    end
  end

  def handleReturns(availabilityMap, c1, c2) do
    Map.put(availabilityMap, c1, :available) |> Map.put(c2, :available)
  end

  def handleRequests(requestMap, cat, hunger, c1, c2, cattoPid) do
    Map.put(requestMap, cat, {hunger, cattoPid, c1, c2})
  end

  def serveRequest(map, availabilityMap) when map == %{} do
    run(Map.new(), availabilityMap)
  end

  def serveRequest(updatedMap, availabilityMap) do
    {{key, {_, cattoPid, c1, c2}}, map} = getLowestIn(updatedMap)
    case checkChopstickPairAvailability(availabilityMap, c1, c2) do
      :sad_face ->
        "#{c1} and #{c2} were NOT available, request denied" |> I_O.print_kernel(key)
        send(cattoPid, :denied)
        run(map, availabilityMap)
      :ok ->
        "#{c1} and #{c2} were available, request approved" |> I_O.print_kernel(key)
        availabilityMap = Map.put(availabilityMap, c1, :taken) |> Map.put(c2, :taken)
        send(cattoPid, {:approved, c1, c2})
        run(map, availabilityMap)
    end
  end

  def checkChopstickPairAvailability(map, c1, c2) do
    case Map.get(map, c1) do
      :taken ->
        :sad_face

      :available ->
        case Map.get(map, c2) do
          :taken -> :sad_face
          :available -> :ok
        end
    end
  end

  defp getLowestIn(map) do
    {key, value} = Enum.min(map)
    {{key, value}, Map.delete(map, key)}
  end
end

defmodule Ticker do
  def ticker(kernelProcess) do
    loadingCat = Task.async(fn -> Cat.meow(:loading, kernelProcess, :c1, :c2, 10, 10, 10, 10) end)
    cryingCat = Task.async(fn -> Cat.meow(:crying, kernelProcess, :c2, :c3, 10, 10, 10, 10) end)
    huhCat = Task.async(fn -> Cat.meow(:huh, kernelProcess, :c3, :c4, 10, 10, 10, 10) end)
    tableCat = Task.async(fn -> Cat.meow(:table, kernelProcess, :c4, :c5, 10, 10, 10, 10) end)
    chipiChipiCat = Task.async(fn -> Cat.meow(:chipiChipi, kernelProcess, :c1, :c5, 10, 10, 10, 10) end)

    Task.await(loadingCat)
    Task.await(cryingCat)
    Task.await(huhCat)
  end
end

defmodule I_O do
  def print(message, cat) do
    "cat     #{cat}    #{message}" |> IO.inspect()
  end

  def print_kernel(message, cat) do
    "kernel  #{cat}    #{message}" |> IO.inspect()
  end
end

availabilityMap =
  Map.new()
  |> Map.put(:c1, :available)
  |> Map.put(:c2, :available)
  |> Map.put(:c3, :available)
  |> Map.put(:c4, :available)
  |> Map.put(:c5, :available)
  |> IO.inspect()

kernelProcess = spawn(Katnel, :run, [Map.new(), availabilityMap])
Ticker.ticker(kernelProcess)
