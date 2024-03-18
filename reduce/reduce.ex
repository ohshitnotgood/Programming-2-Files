defmodule Reduce do
  def length(arg) do
    r_length({0, arg})
  end

  def r_length({x, []}) do
    x
  end

  def r_length({x, [_ | tail]}) do
    r_length({x + 1, tail})
  end

  def even([head | []]) do
    case rem(head, 2) == 0 do
      true -> [head]
      false -> []
    end
  end

  def even([head | tail]) do
    case rem(head, 2) == 0 do
      true -> [head | even(tail)]
      false -> even(tail)
    end
  end

  def inc([head | []]) do
    [head + 1]
  end

  def inc([head | tail]) do
    [c | t] = tail
    [head + 1 | inc([c | t])]
  end

end

defmodule Enuminaty do
  def map([head | []], lambda) do
    [lambda.(head)]
  end

  def map([head | tail], lambda) do
    [c | t] = tail
    [lambda.(head) | map([c | t], lambda)]
  end

  def reduce(src, iac, lambda) do
    do_reduce({iac, src}, lambda)
  end

  def do_reduce({x, [head | []]}, lambda) do
    lambda.(x, head)
  end

  def do_reduce({x, [head | tail]}, lambda) do
    do_reduce({lambda.(x, head), tail}, lambda)
  end

  def filter([head | []], lambda) do
    case lambda.(head) do
      true -> [head]
      false -> []
    end
  end

  def filter([head | tail], lambda) do
    case lambda.(head) do
      true -> [head | filter(tail, lambda)]
      false -> filter(tail, lambda)
    end
  end
end

x = [1, 2, 4, 5, 3, 10]
lambda = fn x, y -> x + y end
Reduce.even(x) |> IO.inspect()
