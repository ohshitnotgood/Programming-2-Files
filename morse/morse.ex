defmodule MorrisCode do
  def decode([], _, _, _, message) do
    message |> IO.puts()
  end

  def decode([?- | rest], {:node, char, left, _}, root, _, message) do
    decode(rest, left, root, char, message)
  end

  def decode([32 | rest], {:node, :na, _, _}, root, _, message) do
    "root char is na na" |> IO.inspect()
    decode(rest, root, root, "", message)
  end

  def decode([32 | rest], {:node, char, _, _}, root, _, message) do
    "adding char " <> <<char::utf8>> |> IO.inspect()
    message = message <> <<char::utf8>>
    decode(rest, root, root, "", message)
  end

  def decode([?. | rest], {:node, char, _, right}, root, _, message) do
    decode(rest, right, root, char, message)
  end
end

defmodule Constants do
  def tree do
    {:node, :na,
     {:node, 116,
      {:node, 109,
       {:node, 111, {:node, :na, {:node, 48, nil, nil}, {:node, 57, nil, nil}},
        {:node, :na, nil, {:node, 56, nil, {:node, 58, nil, nil}}}},
       {:node, 103, {:node, 113, nil, nil},
        {:node, 122, {:node, :na, {:node, 44, nil, nil}, nil}, {:node, 55, nil, nil}}}},
      {:node, 110, {:node, 107, {:node, 121, nil, nil}, {:node, 99, nil, nil}},
       {:node, 100, {:node, 120, nil, nil},
        {:node, 98, nil, {:node, 54, {:node, 45, nil, nil}, nil}}}}},
     {:node, 101,
      {:node, 97,
       {:node, 119, {:node, 106, {:node, 49, {:node, 47, nil, nil}, {:node, 61, nil, nil}}, nil},
        {:node, 112, {:node, :na, {:node, 37, nil, nil}, {:node, 64, nil, nil}}, nil}},
       {:node, 114, {:node, :na, nil, {:node, :na, {:node, 46, nil, nil}, nil}},
        {:node, 108, nil, nil}}},
      {:node, 105,
       {:node, 117, {:node, 32, {:node, 50, nil, nil}, {:node, :na, nil, {:node, 63, nil, nil}}},
        {:node, 102, nil, nil}},
       {:node, 115, {:node, 118, {:node, 51, nil, nil}, nil},
        {:node, 104, {:node, 52, nil, nil}, {:node, 53, nil, nil}}}}}}
  end

  def base,
    do:
      ~c".- .-.. .-.. ..-- -.-- --- ..- .-. ..-- -... .- ... . ..-- .- .-. . ..-- -... . .-.. --- -. --. ..-- - --- ..-- ..- ... "

  def rolled,
    do:
      ~c".... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .---- "

  def sos,
    do: ~c"... ---  ... "
end

defmodule Test do
  def test do
    Constants.rolled() |> MorrisCode.decode(Constants.tree(), Constants.tree(), "", "")
  end
end

Test.test()
