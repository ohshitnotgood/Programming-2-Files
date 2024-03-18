defmodule Mapper do
  def max_pop(a) when a == %{} do
    {nil, %{}}
  end

  def max_pop(a) do
    {key, value} = Enum.max_by(a, fn {_, x} -> x end)
    {_, returning_map} = Map.pop(a, key)
    {{key, value}, returning_map}
  end

  def min_pop(a) when a == %{} do
    {nil, %{}}
  end

  def min_pop(a) do
    {key, value} = Enum.min_by(a, fn {_, x} -> x end)
    {_, returning_map} = Map.pop(a, key)
    {{key, value}, returning_map}
  end
end

defmodule Montelius do
  def tree_start(map) do
    "tree_start called" |> IO.inspect()
    {kv1, map} = Mapper.min_pop(map)
    tree(kv1, map)
  end

  def tree({k1, v1}, map) do
    {{k2, v2}, map} = Mapper.min_pop(map)
    new_leaf = {:leaf, v1 + v2, {:node, k1}, {:node, k2}}
    tree(new_leaf, map)
  end

  def tree(tree, map) when map == %{} do
    tree |> IO.inspect(limit: :infinity)
  end

  def tree({:leaf, v, l, r}, map) do
    {{k2, v2}, map} = Mapper.min_pop(map)
    new_leaf = {:leaf, v + v2, {:node, k2}, {:leaf, v, l, r}}
    tree(new_leaf, map)
  end
end

defmodule Huffman do
  def encode_table(_, freq, encoding_map) when freq == %{} do
    encoding_map
  end

  def encode_table tree, freq, encoding_map do
    {{k, _}, map} = Mapper.min_pop(freq)

    case traverse("", k, tree) do
      {:code, code} ->
        encoding_map = Map.put(encoding_map, k, code)
        encode_table(tree, map, encoding_map)
      {:no_match} -> {:error, "what the fuck?"}
    end
  end

  def encode [], encoded_text, _ do
    encoded_text
  end

  def encode [head | tail], encoded_text, encoding_table do
    encoded_text = encoded_text <> Map.get(encoding_table, <<head::utf8>>)
    encode(tail, encoded_text, encoding_table)
  end

  def decode [], _, _, decoded_text do
    decoded_text
  end

  def decode [48 | tail], {:leaf, v, l, _}, root, decoded_text do
    case l do
      {:node, k} -> decode(tail, root, root, decoded_text <> k)
      leaf -> decode(tail, leaf, root, decoded_text)
    end
  end

  def decode [49 | tail], {:leaf, v, _, r}, root, decoded_text do
    case r do
      {:node, k} -> decode(tail, root, root, decoded_text <> k)
      leaf -> decode(tail, leaf, root, decoded_text)
    end
  end

  def traverse(code, to_find, {:node, to_find}) do
    {:code, code}
  end

  def traverse(_, _, {:node, _}) do
    {:no_match}
  end

  def traverse(code, to_find, {:leaf, _, left, right}) do
    case traverse(code <> "0", to_find, left) do
      {:code, code} -> {:code, code}
      {:no_match} -> traverse(code <> "1", to_find, right)
    end
  end
end

defmodule Praanto do
  def start(map) do
    "start" |> IO.inspect()
    {kv1, map} = Mapper.min_pop(map)
    {kv2, map} = Mapper.min_pop(map)
    start_merge(kv1, kv2, map)
  end

  def start_merge({k1, v1}, {k2, v2}, map) do
    "start_merge" |> IO.inspect()
    new_leaf = {:leaf, v1 + v2, {:node, k1}, {:node, k2}}

    case find_equal_or_larger(map, v1 + v2) do
      {{:found, kx, vx}, _} ->
        {:leaf, v1 + vx, {:node, k1}, {:node, kx}}

      {{:leaf, vx, lx, rx}, _} ->
        next({:leaf, vx + v1 + v2, {:leaf, vx, lx, rx}, new_leaf}, map)
    end
  end

  def next(tree, map) when map == %{} do
    "final next" |> IO.inspect()
    tree
  end

  def next({:leaf, v, l, r}, map) do
    "next" |> IO.inspect()

    new_tree =
      case find_equal_or_larger(map, v) do
        {{:found, kx, vx}, _} -> {:leaf, v + vx, {:node, kx}, {:leaf, v, l, r}}
        {{:leaf, vx, lx, rx}, _} -> {:leaf, vx + v, {:leaf, vx, lx, rx}, {:leaf, v, l, r}}
      end

    {_, map} = Mapper.min_pop(map)
    next(new_tree, map)
  end

  def find_equal_or_larger(map, larger_than) do
    "find_equal or less" |> IO.inspect()

    case Mapper.min_pop(map) do
      {{k1, v1}, map} ->
        case v1 >= larger_than do
          true ->
            "found larger or equal" |> IO.inspect()
            {{:found, k1, v1}, map}

          false ->
            "did not find larger or equal" |> IO.inspect()
            {{:found, k2, v2}, map} = find_equal_or_larger(map, v1)
            {{:leaf, v1 + v2, {:node, k1}, {:node, k2}}, map}
        end

      {nil, %{}} ->
        {{:found, 0, 0}, map}
    end
  end
end

defmodule Wikipedia do
  def tree_start(map) do
    {{k1, v1}, map} = Mapper.max_pop(map)

    case match_value(map, v1) do
      {:not_matched} -> "no match found" |> IO.inspect()
      {:leaf, vx, lx, rx} -> {:leaf, v1 + vx, {:node, k1}, {:leaf, vx, lx, rx}}
    end
  end

  def match_value(map, value) do
    {{k1, v1}, map} = Mapper.max_pop(map)

    case v1 == value do
      true ->
        {:matched, {:node, k1, v1}}

      false ->
        case v1 > value do
          false ->
            case match_value(map, v1) do
              {:matched, {:node, kx, vx}} -> {:leaf, v1 + vx, {:node, k1}, {:node, kx}}
              {:leaf, vx, lx, rx} -> {:leaf, v1 + vx, {:node, k1}, {:leaf, vx, lx, rx}}
            end

          true ->
            {:not_matched}
        end
    end
  end
end

defmodule FIFO do
  def push([], el) do
    [el]
  end

  def push(list, el) do
    list ++ [el]
  end

  def push_last([], el) do
    [el]
  end

  def push_last(list, el) do
    [el | list]
  end

  def pop([]) do
    nil
  end

  def pop([head | tail]) do
    {head, tail}
  end
end

defmodule FIFOMethod do
  def tree_start(map) do
    first([], map)
  end

  def first(fifo, map) do
    {kv1, map} = Mapper.min_pop(map)
    {kv2, map} = Mapper.min_pop(map)
    fifo = FIFO.push(fifo, merge(kv1, kv2))
    next(fifo, map)
  end

  def next(fifo, map) when map == %{} do
    clean_fifo(fifo)
  end

  def next(fifo, map) do
    {{k1, v1}, map} = Mapper.min_pop(map)
    {{:leaf, vx, lx, rx}, fifo} = FIFO.pop(fifo)

    case v1 >= vx do
      false ->
        fifo = FIFO.push_last(fifo, {:leaf, vx, lx, rx})
        map = Map.put(map, k1, v1)
        first(fifo, map)

      true ->
        fifo = FIFO.push(fifo, {:leaf, v1 + vx, {:node, k1}, {:leaf, vx, lx, rx}})
        next(fifo, map)
    end
  end

  def merge({k1, v1}, {k2, v2}) do
    {:leaf, v1 + v2, {:node, k1}, {:node, k2}}
  end

  def merge({k1, v1}, {:leaf, vx, lx, rx}) do
    {:leaf, v1 + vx, {:node, k1}, {:leaf, vx, lx, rx}}
  end

  def clean_fifo(fifo) do
    case FIFO.pop(fifo) do
      {last, []} ->
        last

      {{:leaf, v, l, r}, fifo} ->
        case FIFO.pop(fifo) do
          {{:leaf, v_last, l_l, r_l}, []} ->
            {:leaf, v + v_last, {:leaf, v, l, r}, {:leaf, v_last, l_l, r_l}}

          {{:leaf, v_last, l_l, r_l}, fifo} ->
            fifo =
              FIFO.push(fifo, {:leaf, v + v_last, {:leaf, v, l, r}, {:leaf, v_last, l_l, r_l}})

            clean_fifo(fifo)
        end
    end
  end
end

defmodule Frequency do
  def freq(sample) do
    freq(String.to_charlist(sample), Map.new())
  end

  def freq([], freq) do
    freq
  end

  def freq([char | rest], freq) do
    char_freq = Map.get(freq, <<char::utf8>>, 0)
    freq = Map.put(freq, <<char::utf8>>, char_freq + 1)
    freq(rest, freq)
  end
end

defmodule Test do
  def test do
    test_string = File.read!("./test.txt")

    freq = Frequency.freq(test_string)

    # freq |> Praanto.start |> IO.inspect(limit: :infinity) |> Huffman.encode_table(freq) |> IO.inspect(limit: :infinity)
    # freq |> Montelius.tree_start |> IO.inspect(limit: :infinity) |> Huffman.encode_table(freq) |> IO.inspect(limit: :infinity)
    # freq |> Wikipedia.tree_start |> IO.inspect(limit: :infinity) |> Huffman.encode_table(freq) |> IO.inspect(limit: :infinity)
    # tree = freq |> FIFOMethod.tree_start()
    tree = freq |> FIFOMethod.tree_start() |> IO.inspect()
    encoding_table = tree |> Huffman.encode_table(freq, Map.new()) |> IO.inspect(limit: :infinity)
    encoded_text = Huffman.encode(String.to_charlist(test_string), "", encoding_table) |> String.length() |> IO.inspect()
    # String.to_charlist(encoded_text) |> IO.inspect()
    # Huffman.decode(String.to_charlist(encoded_text), tree, tree, "") |> IO.inspect()
  end
end

Test.test()
