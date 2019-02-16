defmodule ColtraneTest do
  use ExUnit.Case
  alias Coltrane.Theory.{Note, Interval, PitchClass, Frequency, Scale}

  doctest Interval
  doctest Note
  doctest PitchClass
  doctest Frequency
  doctest Scale
end
