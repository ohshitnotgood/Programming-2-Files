defmodule EnvTree do
  def new(n) do
    {:node, n, {:node, nil}, {:node, nil}}
  end

  def add({:node, nil}, value) do
    {:node, value, {:node, nil}, {:node, nil}}
  end

  def add({:node, key, left, right}, new_value) do
    if new_value < key do
      if left == {:node, nil} do
        {:node, key, {:node, new_value, {:node, nil}, {:node, nil}}, right}
      else
        {:node, key, add(left, new_value), right}
      end
    else
      if right == {:node, nil} do
        {:node, key, left, {:node, new_value, {:node, nil}, {:node, nil}}}
      else
        {:node, key, left, add(left, new_value)}
      end
    end
  end
end

defmodule EnvTreeRemove do
  # If no element is found
  def remove({:node, nil}, _) do
    :no
  end

  # Removes if the root is the element we look for
  def remove({:node, key, _, _}, key) do
    {:node, nil}
  end

  # Removes the left branch
  def remove({:node, key, {:node, val, _, _}, don_t_care}, val) do
    {:node, key, {:node, nil}, don_t_care}
  end

  # Removes the right branch
  def remove({:node, key, don_t_care, {:node, val, _, _}}, val) do
    {:node, key, don_t_care, {:node, nil}}
  end

  # If neither branch should be removed, then picks a side
  def remove({:node, key, left, right}, val) do
    if val < key do
      {:node, key, remove(left, key), right}
    else {:node, key, left, remove(left, key)}
    end
  end

  # Promote left
  def promote({:node, _, {:node, nil}, right}) do
    {:node, left, promote(left), right}
  end

  # Promote right
  def promote({:node, _, left, right}) do
    {:node, right, left, promote(right)}
  end

  def promote({:node, _, {:node, left, left_left, left_right}, {:node, right, right_left, right_right}}) do
    if left < right do
      {:node, left, promote({:node, left, left_left, left_right}), {:node, right, right_left, right_right}}
    else
      {:node, left, {:node, left, left_left, left_right}, promote({:node, right, right_left, right_right})}
    end
  end
end
# list |> IO.inspect()

r = EnvTree.new(41) |> EnvTree.add(30) |> EnvTree.add(50) |> EnvTree.add(32) |> EnvTree.add(42) |> EnvTree.add(44) |> EnvTree.add(43)
r |> IO.inspect()

# r |>  EnvTreeRemove.remove(24) |> IO.inspect()

# Benchmark.each_element_benchmark()
