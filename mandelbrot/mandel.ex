defmodule Cmplx do
  def new(r, i) do
    {r, i}
  end

  def add({ra, ia}, {rb, ib}) do
    {ra + rb, ia + ib}
  end

  def sqr(0) do
    {0, 0}
  end

  def sqr({r, b}) do
    {r * r - b * b, 2 * r * b}
  end

  def abs(0) do
    0
  end

  def abs({r, i}) do
    :math.sqrt(r * r + i * i)
  end
end

defmodule Brod do
  def mandelbrot(_, _, _, 0) do
    # "Fail!" |> IO.puts()
    0
  end

  def mandelbrot(z, c, m, dci) do
    # "z is " |> IO.write()
    # z |> IO.inspect()
    # "c is " |> IO.write()
    # c |> IO.inspect()

    case Cmplx.abs(z) > 2 do
      true ->
        # "mandelbrot!" |> IO.puts()
        m - (dci - 1)

      false ->
        mandelbrot(Cmplx.add(c, Cmplx.sqr(z)), c, m, dci - 1)
    end
  end

  def mandelbrot(c, m) do
    mandelbrot(0, c, m, m)
  end
end

defmodule Colour do
  def convert(depth, max) do
    fraction = depth / max
    a = fraction * 4
    x = trunc(a)
    y = trunc(255 * (a - x))

    case x do
      0 -> {:rgb, y, 0, 0}
      1 -> {:rgb, 0, 255 - y, 255}
      2 -> {:rgb, 0, 255, y}
      4 -> {:rgb, 255, y, 0}
      3 -> {:rgb, 255 - y, 255, 0}
    end
  end
end

defmodule PPM do
  def write(name, image) do
    height = length(image)
    width = length(List.first(image))
    {:ok, fd} = File.open(name, [:write])
    IO.puts(fd, "P6")
    IO.puts(fd, "#generated by ppm.ex")
    IO.puts(fd, "#{width} #{height}")
    IO.puts(fd, "255")
    rows(image, fd)
    File.close(fd)
  end

  defp rows(rows, fd) do
    Enum.each(rows, fn r ->
      colours = row(r)
      IO.write(fd, colours)
    end)
  end

  defp row(row) do
    List.foldr(row, [], fn {:rgb, r, g, b}, a ->
      [r, g, b | a]
    end)
  end
end

defmodule Mandel do
  def mandelbrot(width, height, x, y, k, depth) do
    trans = fn w, h ->
      Cmplx.new(x + k * (w - 1), y - k * (h - 1))
    end

    rows(width, height, trans, depth, [])
  end

  def rows(_, 0, _, _, row) do
    row
  end

  def rows(width, height, trans, depth, row) do
    new_row = gen_width(width, height, [], trans, depth)
    rows(width, height - 1, trans, depth, row ++ [new_row])
  end

  def gen_width(0, _, r, _, _) do
    r
  end


  def gen_width(width, height, r, trans, depth) do
    complex = trans.(width, height)
    i = Brod.mandelbrot(complex, depth)
    colour = Colour.convert(i, depth)
    gen_width(width - 1, height, [ colour | r], trans, depth)
  end
end

defmodule ArshiNogor do
  def demo() do
    small(-5, 2.420, 1.69)
  end

  def small(x0, y0, xn) do
    width = 960
    height = 540
    depth = 64
    k = (xn - x0) / width
    image = Mandel.mandelbrot(width, height, x0, y0, k, depth)
    image |> IO.inspect()
    PPM.write("new_ex.ppm", image)
  end
end

ArshiNogor.demo()
