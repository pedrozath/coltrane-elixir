defmodule Coltrane.Theory.Scale do
  @moduledoc """
  This module contains functions to manipulate scales.
  """

  alias Coltrane.Theory.{Note, Scale, Interval}
  @enforce_keys [:root, :intervals]
  defstruct(root: nil, intervals: nil)

  @doc """
      iex> Scale.major("C") |> Scale.notes |> Enum.map(&Note.name/1)
      ["C", "D", "E", "F", "G", "A", "B"]

      iex> Scale.major("C#") |> Scale.notes |> Enum.map(&Note.name/1)
      ["C#", "D#", "E#", "F#", "G#", "A#", "B#"]

      iex> Scale.major("D") |> Scale.notes |> Enum.map(&Note.name/1)
      ["D", "E", "F#", "G", "A", "B", "C#"]

      iex> Scale.major("Eb") |> Scale.notes |> Enum.map(&Note.name/1)
      ["Eb", "F", "G", "Ab", "Bb", "C", "D"]

      iex> Scale.major("B#") |> Scale.notes |> Enum.map(&Note.name/1)
      ["B#", "C##", "D##", "E#", "F##", "G##", "A##"]
  """
  def major(root) do
    intervals = Interval.from_notation("5P") |> Interval.circle
    %Scale{intervals: intervals, root: root}
  end

  def notes(%Scale{root: root, intervals: intervals}) do
    for interval <- intervals, do: Note.transpose(root, interval)
  end
end
