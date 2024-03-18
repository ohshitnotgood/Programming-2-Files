defmodule MultiDimArray do
  def new(x, y) do
    new(x, y, [])
  end

  def new(_, 0, r) do
    r
  end

  def new(x, y, r) do
    width = gen_width(x, [])
    new(x, y - 1, r ++ [width])
  end


  def gen_width(0, r) do
    r
  end

  def gen_width(x, r) do
    gen_width(x - 1, [ {:rgb, 255, 0, 255} | r ])
  end

  def find(array, x, y) do
    row = Enum.at(array, x)
    Enum.at(row, y)
  end

  def put(array, x, y, val) do
    row = Enum.at(array, y)
    replaced = replace_at(row, x, val)
    replace_at(array, y, replaced)
  end

  def replace_at list, index, value do
    list
    |> Enum.with_index()
    |> Enum.map(fn
      {_, ^index} -> value # match index
      {value, _} -> value  # anything else
    end)
  end
end
