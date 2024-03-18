defmodule MapGenerator do
  def get_maps all_maps do
    for each_map <- all_maps do
      List.to_tuple(Enum.map(each_map, fn x -> x |> String.to_integer end))
    end |> convert_list_to_map(Map.new())
  end

  defp generate_map map, {_, _, 0} do
    map
  end

  defp generate_map map, {dest, src, f_length} do
    generate_map Map.put(map, src, dest), {dest + 1, src + 1, f_length - 1}
  end


  defp convert_list_to_map [], map do
    map
  end

  defp convert_list_to_map [head | tail], map do
    convert_list_to_map(tail, generate_map(map, head))
  end
end

defmodule Parser do
  def parseSeeds do
    case File.read("./data/seeds.txt") do
      {:ok, data} -> Enum.filter(String.split(data, ","), fn x -> x != "" end)
      {:error, msg} -> {:error, msg}
    end
  end

  def getSeed2Soil do
    parseListOfLists("./data/seed2soil.csv") |> MapGenerator.get_maps()
  end

  def getSoil2Fart do
    parseListOfLists("./data/soil2fart.csv") |> MapGenerator.get_maps()
  end

  def getFart2Water do
    parseListOfLists("./data/fart2water.csv") |> MapGenerator.get_maps()
  end

  def getWater2Ljus do
    parseListOfLists("./data/water2ljus.csv") |> MapGenerator.get_maps()
  end

  def getLjus2Temp do
    parseListOfLists("./data/ljus2temp.csv") |> MapGenerator.get_maps()
  end

  def getTemp2Hum do
    parseListOfLists("./data/temp2hum.csv") |> MapGenerator.get_maps()
  end

  def getHum2Pos do
    parseListOfLists("./data/hum2pos.csv") |> MapGenerator.get_maps()
  end

  defp parseListOfLists filename do
    case File.read(filename) do
      {:ok, data} ->
        Enum.filter(Enum.map(String.split(data, "\n"), fn x -> String.split(x, ",") end), fn x -> x != [""] end)
      {:error, msg} -> {:error, msg}
    end
  end
end

defmodule Tester do
  def test do
    Parser.getSeed2Soil() |> Map.get(79) |> IO.inspect()
    Parser.getSoil2Fart() |> Map.get(81, 81) |> I_O.inspect()
    Parser.getFart2Water() |> Map.get(81, 81) |> I_O.inspect()
    Parser.getWater2Ljus() |> Map.get(81) |> I_O.inspect()
    Parser.getLjus2Temp() |> Map.get(74) |> I_O.inspect()
    Parser.getTemp2Hum() |> Map.get(78, 78) |> I_O.inspect()
    Parser.getHum2Pos() |> Map.get(78) |> I_O.inspect()
  end

  def rigamarole do
    Parser.parseSeeds() |> Enum.map(fn x -> String.to_integer(x) |> r() |> IO.inspect() end)
  end

  def r x do
    seed2soil = Parser.getSeed2Soil() |> Map.get(x, x)
    soil2fart = Parser.getSoil2Fart() |> Map.get(seed2soil, seed2soil)
    fart2water = Parser.getFart2Water() |> Map.get(soil2fart, soil2fart)
    water2ljus = Parser.getWater2Ljus() |> Map.get(fart2water, fart2water)
    ljus2temp = Parser.getLjus2Temp() |> Map.get(water2ljus, water2ljus)
    temp2hum = Parser.getTemp2Hum() |> Map.get(ljus2temp, ljus2temp)
    Parser.getHum2Pos() |> Map.get(temp2hum, temp2hum)
  end
end

defmodule I_O do
  def inspect a do
    a |> IO.inspect(charlists: :as_list)
  end
end

# Seeds.start() |> IO.inspect()
# MapGenerator.generate_map(Map.new(), 50, 98, 2) |> IO.inspect()
# MapGenerator.convert_string_list_to_int_list(["1", "3", "5"]) |> IO.inspect()
Tester.rigamarole()
