defmodule Environment do
  def new do
    Map.new()
  end

  def new(env) do
    Map.new(env)
  end
end

defmodule Expr do
  def eval({:num, n}, _) do
    {:num, n}
  end

  # Returns values of variables stored in our 'environment'
  def eval({:var, x}, env) do
    Map.get(env, x)
  end

  def eval({:add, arg0, arg1}, env) do
    add(eval(arg0, env), eval(arg1, env))
  end

  def eval({:sub, arg0, arg1}, env) do
    sub(eval(arg0, env), eval(arg1, env))
  end


  def eval({:mul, arg0, arg1}, env) do
    mul(eval(arg0, env), eval(arg1, env))
  end

  # Evaluates a division.
  # Cannot be bothered to do the quotients.
  def eval({:div, arg0, arg1}, env) do
    divide(eval(arg0, env), eval(arg1, env))
  end


  def add({:num, f1}, {:num, f2}) do
    {:num, f1 + f2}
  end


  def sub({:num, f1}, {:num, f2}) do
    {:num, f1 - f2}
  end

  def mul({:num, f1}, {:num, f2}) do
    {:num, f1 * f2}
  end

  def divide({:num, f1}, {:num, f2}) do
    {:num, f1 / f2}
  end
end


defmodule ComeOn do
  def do_math do
    env = Environment.new([{:x, {:num, 5}}, {:y, {:num, 3}}])
    expression = {:add, {:div, {:var, :x}, {:var, :y}}, {:mul, {:mul, {:var, :x}, {:var, :y}}, {:num, 4}}}
    Expr.eval(expression, env) |> IO.inspect()
  end
end

ComeOn.do_math()
