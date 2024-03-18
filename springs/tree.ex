defmodule Tree do
  def new_tree(pattern) do
    case String.at(pattern, 0) do
      "?" -> {:node, :unknown, generate_tree({:left, pattern, 1}), generate_tree({:right, pattern, 1})}
      "." -> {:node, :working, generate_tree({:left, pattern, 1}), {:node, nil}}
      "#" -> {:node, :broken, {:node, nil}, generate_tree({:right, pattern, 1})}
      _ -> {:error, "Error parsing string"}
    end
  end

  def generate_tree({:left, pattern, index}) do
    case String.at(pattern, index) do
      "?" ->
        {:node, :unknown, generate_tree({:left, pattern, index + 1}),
         generate_tree({:right, pattern, index + 1})}

      "." ->
        {:node, :working, generate_tree({:left, pattern, index + 1}), {:node, nil}}

      "#" ->
        {:node, :broken, {:node, nil}, generate_tree({:right, pattern, index + 1})}

      nil -> {:node, nil}
      _ ->
        {:error, "Error parsing string"}
    end
  end

  def generate_tree({:right, pattern, index})do
    case String.at(pattern, index) do
      "?" ->
        {:node, :unknown, generate_tree({:left, pattern, index + 1}),
         generate_tree({:right, pattern, index + 1})}

      "." ->
        {:node, :working, generate_tree({:left, pattern, index + 1}), {:node, nil}}

      "#" ->
        {:node, :broken, {:node, nil}, generate_tree({:right, pattern, index + 1})}

      nil -> {:node, nil}
      _ ->
        {:error, "Error parsing string"}
    end
  end
end

defmodule Stack do
  def new do
    []
  end

  def push(stack, {:node, nil}) do
    {stack, nil}
  end

  def push(stack, a) do
    id = length(stack) + 1
    {[{:s_el, id, a} | stack], id}
  end

  def pop([]) do
    {:stack_empty, []}
  end

  def pop(from_stack) do
    [head | tail] = from_stack
    {head, tail}
  end
end

defmodule LastTime do
  def traverse_begin(node, clue, raw_pattern) do
    traverse_branch(node, {clue, 0, false}, {0, false}, {raw_pattern, "", false}, [])
  end

  def traverse({:node, nil}, {_, _, true}, _, {_, result, true}, []) do
    result |> I_O.print_success()
    "code 0" |>  I_O.print_exit()
  end

  def traverse({:node, nil}, {_, _, false}, _, {_, _, true}, []) do
    "all_failed"|> I_O.print_exit()
  end

  def traverse({:node, nil}, {clue, _, clue_match}, _, {raw_pattern, result, true}, stack) do
    case clue_match do
      true -> "result #{result}. clue_match #{clue_match}" |> I_O.print_success()
      false -> "result #{result}# clue_match #{clue_match}" |> I_O.print_fail()
    end
    {{:s_el, id, {p_node, p_clue_index, p_rows, p_result}}, p_stack} = Stack.pop(stack)
    "id: " <> Integer.to_string(id) <> " result>" <> p_result <> "<rows " <> Integer.to_string(p_rows) <> " clue_index " <> Integer.to_string(p_clue_index) |> I_O.print_stack_pop()
    update_clue(p_node, get_clue_index(clue, p_clue_index), update_rows(p_rows, clue, p_clue_index), update_result(raw_pattern, p_result), p_stack)
  end

  def traverse(node, clues, rows, pattern, stack) do
    "traverse/generic" |> I_O.print_traverse()
    traverse_branch(node, clues, rows, pattern, stack)
  end

  def update_clue({:node, _, {:node, nil}, _}, {clue, clue_index, _}, {_, true}, {raw_pattern, result, _}, stack) do
    "update_clue@left_branch=nil?row==true?result=#{result} >> failed effort, traverse_from stack" |> I_O.print_update_clue()
    traverse({:node, nil}, increment_clue_index(clue, clue_index), {0, false}, {raw_pattern, result, true}, stack)
  end

  def update_clue({:node, :unknown, left, _}, {clue, clue_index, _}, {_, true}, {raw_pattern, result, _}, stack) do
    "update_clue@branch==unknown?row==true?result=#{result} >> increment clue_index, reset raw, force take left branch" |> I_O.print_update_clue()
    traverse_branch(left, increment_clue_index(clue, clue_index), {0, false}, working_result(raw_pattern, result), stack)
  end

  def update_clue(node, {clue, clue_index, _}, {_, true}, {raw_pattern, result, _}, stack) do
    "update_clue@row==true?result=#{result} >> increment clue_index, resetting raw" |> I_O.print_update_clue()
    traverse(node, increment_clue_index(clue, clue_index), {0, false}, update_result(raw_pattern, result), stack)
  end

  def update_clue(node, {clue, clue_index, match_already_found}, {rows, false}, {raw_pattern, result, _}, stack) do
    "update_clue@row==false?result=#{result} >> no update" |> I_O.print_update_clue()
    traverse(node, {clue, clue_index, match_already_found}, {rows, false}, update_result(raw_pattern, result), stack)
  end

  def traverse_branch({:node, :unknown, left, right}, {clue, clue_index, false}, {rows, rows_match}, {raw_pattern, result, _}, stack) do
    "traverse_branch@branch==unknown?clue_match==false" |> I_O.print_branch()
    {s, id} = Stack.push(stack, {right, clue_index, rows + 1, result <> "#"})
    "id #{Integer.to_string(id)} result #{result}# rows #{Integer.to_string(rows)} clue_index #{Integer.to_string(clue_index)}" |> I_O.print_stack_push()
    update_clue(left, {clue, clue_index, false}, {rows, rows_match}, working_result(raw_pattern, result), s)
  end

  def traverse_branch({:node, :unknown, left, _}, {clue, clue_index, true}, {_, _}, {raw_pattern, result, _}, stack) do
    "traverse_branch@branch==unknown?clue_match==true >> reset raw" |> I_O.print_branch()
    update_clue(left, {clue, clue_index, true}, {0, false}, working_result(raw_pattern, result), stack)
  end

  def traverse_branch({:node, :broken, _, right}, {clue, clue_index, false}, {rows, row_matched}, {raw_pattern, result, _}, stack) do
    "traverse_branch@branch=broken?clue_match=false >> increment rows" |> I_O.print_branch()
    update_clue(right, {clue, clue_index, false}, increment_rows(rows, clue, clue_index), broken_result(raw_pattern, result), stack)
  end

  def traverse_branch({:node, :broken, _, right}, {clue, clue_index, true}, {rows, row_matched}, {raw_pattern, result, _}, stack) do
    "traverse_branch@branch=broken?clue_match=true >> time for traversing" |> I_O.print_branch()
    traverse({:node, nil}, {clue, clue_index, true}, {0, false}, {raw_pattern, result, true}, stack)
  end


  def traverse_branch({:node, :working, left, _}, clue, rows, {raw_pattern, result, _}, stack) do
    "traverse_branch@branch=working" |> I_O.print_branch()
    update_clue(left, clue, rows, working_result(raw_pattern, result), stack)
  end

  def broken_result(raw_pattern, result) do
    {raw_pattern, result <> "#", String.length(raw_pattern) == String.length(result) + 1}
  end

  def working_result(raw_pattern, result) do
    {raw_pattern, result <> ".", String.length(raw_pattern) == String.length(result) + 1}
  end

  def update_result(raw_pattern, result) do
    {raw_pattern, result, String.length(raw_pattern) == String.length(result)}
  end

  def get_clue_index(clue, clue_index) do
    {clue, clue_index, clue_index == length(clue)}
  end

  def increment_clue_index(clue, clue_index) do
    {clue, clue_index + 1, clue_index + 1 >= length(clue)}
  end

  def update_rows(rows, clue, clue_index) do
    {rows, Enum.at(clue, clue_index) == rows}
  end

  def increment_rows(rows, clue, clue_index) do
    {rows + 1, Enum.at(clue, clue_index) == rows + 1}
  end

  def update_clue_index(clue, clue_index) do
    {clue, clue_index, length(clue) == clue_index}
  end
end

defmodule I_O do
  def print_branch(a) do
    "branch     " <> a |> IO.inspect()
  end

  def print_update_clue(a) do
    "clue       " <> a |> IO.inspect()
  end

  def print_traverse(a) do
    "traverse   " <> a |> IO.inspect()
  end

  def print_stack_push(a) do
    "stack_push " <> a |> IO.inspect()
  end

  def print_stack_pop(a) do
    "stack_pop  " <> a |> IO.inspect()
  end

  def print_exit(a) do
    "exit       " <> a |> IO.inspect()
  end

  def print_success(a) do
    "success    " <> a |> IO.inspect()
  end

  def print_fail(a) do
    "fail       " <> a |> IO.inspect()
  end
end


defmodule Benchmark do
  def test([]) do
    :exit_code_0
  end

  def test([head | tail]) do
    {pattern, clue} = head
    {time, _} = :timer.tc(fn -> Tree.new_tree(pattern) |> LastTime.traverse_begin(clue, pattern) end)
    "#{pattern |> String.graphemes |> Enum.count(& &1 == "?") |> Integer.to_string()}, #{Integer.to_string(time)}, #{String.length(pattern) |> Integer.to_string()}"|> IO.inspect()
    test(tail)
  end

  def do_test({pattern, clue}) do
    Tree.new_tree(pattern) |> LastTime.traverse_begin(clue, pattern)
    "Moving to next pattern" |> IO.inspect()
  end
end

defmodule FileReader do
  def pathToFile(a) do
    File.read(a) |> parseFile()
  end

  def parseFile({:ok, a}) do
    String.split(a, "\n") |> parseFirstLine([])
  end

  def parseFirstLine([], r) do
    r
  end

  def parseFirstLine([head | tail], r) do
    parseFirstLine(tail, splitAtSpace(head, r))
  end

  def splitAtSpace(line, r) do
    [pattern | clue] = String.split(line, " ")
    [{pattern, splitClueAtComma(clue)} | r]
  end

  def splitClueAtComma(clue) do
    String.split(Enum.at(clue, 0), ",") |> Enum.map(fn x -> String.to_integer(x) end)
  end
end

FileReader.pathToFile("./test.txt") |> Benchmark.test()
