defmodule EnvList do
  def new do
    []
  end

  def add(list, key, value) do
    new_tuple = {String.to_atom(key), value}
    [new_tuple | list] |> List.keysort(0)
  end

  def lookup(list, key) do
    BinarySearch.search(list, key)
  end
end

defmodule BinarySearch do
  def search(list, key) do

  end

  defp recursively(list, key, low, high) when low <= high do
    mid = div(low + high, 2)
  end
end


EnvList.new() |> EnvList.add("a", 32) |> EnvList.add("b", 31) |> EnvList.add("c", 30) |> EnvList.add("d", 29) |> IO.inspect()
