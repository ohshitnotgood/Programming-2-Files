defmodule Test do
  def test(map) when map == %{} do
    "empty" |> IO.inspect()
    self() |> IO.inspect()
  end

  def test(_) do
    "full" |> IO.inspect()
    self() |> IO.inspect()
  end
end

Map.new() |> IO.inspect() |> Test.test()
Map.new() |> Map.put(1, 44) |> IO.inspect() |> Test.test()

defmodule Cat do
  def send(:left_ok, c1, c2, c1Pid, c2Pid, base_hunger hunger) do
    receive do
      {c2, :approve} ->
        eat()
        return()
        sleep()
        send(:pending, c1, c2, c1Pid, c2Pid, base_hunger, hunger)
      {c2, :denied} ->
        send(:pending, c1, c2, c1Pid, c2Pid, base_hunger, hunger - 1)
    end
  end

  def send(:right_ok, c1, c2, c1Pid, c2Pid, base_hunger, hunger) do
    receive do
      {c1, :approve} ->
        eat()
        return()
        sleep()
        send(:pending, c1, c2, c1Pid, c2Pid, base_hunger, hunger)
      {c1, :denied} ->
        send(:pending, c1, c2, c1Pid, c2Pid, base_hunger, hunger - 1)
    end
  end

  def send(:pending, c1, c2, c1Pid, c2Pid, base_hunger, hunger) do
    send(c1Pid, {:request, self(), hunger})
    send(c2Pid, {:request, self(), hunger})

    receive do
      {c1, :approve} -> send{:left_ok, c1, c2, c1Pid, c2Pid, base_hunger, hunger}
      {c2, :approve} -> send{:right_ok, c1, c2, c1Pid, c2Pid, base_hunger, hunger}
      {chopstickAtom, :denied} -> send{:pending, c1, c2, c1Pid, c2Pid, base_hunger, hunger - 1}
    end
  end
end
