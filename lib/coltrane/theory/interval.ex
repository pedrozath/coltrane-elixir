defmodule Coltrane.Theory.Interval do
  @moduledoc """
  Intervals describe the relationship between 2 different notes
  """

  alias Coltrane.Theory.{Note, Interval}
  defstruct alteration: 0, letter_distance: @enforce_keys([:letter_distance])

  @quality_sequence          ["P", "M", "M", "P", "P", "M", "M"]
  @letter_distance_semitones [ 0,   2,   4,   5,   7,   9,  11]

  @quality_values %{
    "m" => -1,
    "D" => -1,
    "P" => 0,
    "M" => 0,
    "A" => 1
  }

  @quality_abbreviations %{
    "DDD" => "Triple Diminished",
    "DD"  => "Double Diminished",
    "D"   => "Diminished",
    "AAA" => "Triple Augmented",
    "AA"  => "Double Augmented",
    "A"   => "Augmented",
    "M"   => "Major",
    "m"   => "Minor",
    "P"   => "Perfect"
  }

  @letter_distances_names [
    "Unison",
    "Second",
    "Third",
    "Fourth",
    "Fifth",
    "Sixth",
    "Seventh"
  ]

  @doc """
    iex> Interval.name(%Interval{letter_distance: 0, alteration: 0})
    "1P"

    iex> Interval.name(%Interval{letter_distance: 2, alteration: 0})
    "3M"

    iex> Interval.name(%Interval{letter_distance: 1, alteration: -1})
    "2m"

    iex> Interval.name(%Interval{letter_distance: 2, alteration: -1})
    "3m"

    iex> Interval.name(%Interval{letter_distance: 3, alteration: 1})
    "4A"

    iex> Interval.name(%Interval{letter_distance: 3, alteration: 2})
    "4AA"
  """
  def name(%Interval{letter_distance: letter_distance, alteration: alteration}) do
    Enum.at(@quality_sequence, letter_distance)
    |> (&(((abs(letter_distance) + 1) |> to_string) <> alter_quality(&1, alteration))).()
  end

  @doc """
    iex> Interval.full_name(%Interval{letter_distance: 3, alteration: -1})
    "Diminished Fourth"

    iex> Interval.full_name(%Interval{letter_distance: 2, alteration: 0})
    "Major Third"
  """
  def full_name(interval = %Interval{}) do
    interval |> name |> expand_name
  end

  @doc """
    iex> Interval.expand_name("1P")
    "Perfect Unison"

    iex> Interval.expand_name("3m")
    "Minor Third"

    iex> Interval.expand_name("5A")
    "Augmented Fifth"

    iex> Interval.expand_name("5AAA")
    "Triple Augmented Fifth"

    iex> Interval.expand_name("1DD")
    "Double Diminished Unison"
  """
  def expand_name(name) do
    {distance, quality} = String.split_at(name, 1)
    "#{expand_quality_name(quality)} #{expand_distance_name(distance)}"
  end

  def expand_quality_name(quality), do: @quality_abbreviations[quality]

  def expand_distance_name(letter_distance) do
    Integer.parse(letter_distance)
    |> elem(0)
    |> (&Enum.at(@letter_distances_names, &1 - 1)).()
  end

  @doc """
    iex> Interval.alter_quality("M", 0)
    "M"

    iex> Interval.alter_quality("M", 1)
    "A"

    iex> Interval.alter_quality("M", -1)
    "m"

    iex> Interval.alter_quality("M", -2)
    "D"

    iex> Interval.alter_quality("M", -3)
    "DD"

    iex> Interval.alter_quality("P", 0)
    "P"

    iex> Interval.alter_quality("P", 1)
    "A"

    iex> Interval.alter_quality("P", -1)
    "D"

    iex> Interval.alter_quality("P", -2)
    "DD"

    iex> Interval.alter_quality("P", 2)
    "AA"
  """
  def alter_quality(quality, 0), do: quality
  def alter_quality(_, alteration) when alteration > 0, do: String.duplicate("A", alteration)

  def alter_quality("M", alteration) when alteration < 0, do: alter_quality("m", alteration + 1)
  def alter_quality(_, alteration) when alteration < 0, do: String.duplicate("D", abs(alteration))

  @doc """
      iex> Interval.from_notation("1P")
      %Interval{letter_distance: 0, alteration: 0}

      iex> Interval.from_notation("2M")
      %Interval{letter_distance: 1, alteration: 0}

      iex> Interval.from_notation("3m")
      %Interval{letter_distance: 2, alteration: -1}

      iex> Interval.from_notation("4m")
      %Coltrane.Theory.Interval{alteration: -1, letter_distance: 3}

      iex> Interval.from_notation("5AA")
      %Interval{letter_distance: 4, alteration: 2}
  """
  def from_notation(notation) do
    {letter_distance, alteration} = String.split_at(notation, 1)
    d = Integer.parse(letter_distance) |> elem(0) |> Kernel.-(1)
    a = String.graphemes(alteration) |> Enum.map(&@quality_values[&1]) |> Enum.reduce(&Kernel.+/2)
    %Interval{letter_distance: d, alteration: a}
  end

  @doc """
  This function gets the interval between 2 notes

  ## Examples
    iex> Interval.between("C", "C#")
    %Interval{alteration: 1, letter_distance: 0}

    iex> Interval.between("C", "D")
    %Interval{alteration: 0, letter_distance: 1}

    iex> Interval.between("C", "D")
    %Interval{letter_distance: 1, alteration: 0}
  """
  def between(
        first_note = %Note{base_pitch_class: first_letter, alteration: first_alteration},
        second_note = %Note{base_pitch_class: second_letter, alteration: second_alteration}
      ) do
    %Interval{
      letter_distance: letter_distance(Note.letter(first_note), Note.letter(second_note)),
      alteration: second_alteration - first_alteration
    }
  end

  def between(first_note, second_note) do
    between(
      Note.from_notation(first_note),
      Note.from_notation(second_note)
    )
  end

  @doc """
  ## Examples:
    iex> Interval.letter_distance("C", "D")
    1

    iex> Interval.letter_distance("D", "C")
    -1

    iex> Interval.letter_distance("C", "B")
    6

    iex> Interval.letter_distance("B", "C")
    -6
  """
  def letter_distance(first_letter, second_letter) do
    Enum.find_index(Note.letters(), &(&1 == second_letter)) -
      Enum.find_index(Note.letters(), &(&1 == first_letter))
  end

  @doc """
      iex> ["3M", "3M"]
      ...> |> Enum.map(&Interval.from_notation/1)
      ...> |> Enum.reduce(&Interval.sum/2)
      ...> |> Interval.name
      "5P"

      iex> ["3M", "3m", "3M"]
      ...> |> Enum.map(&Interval.from_notation/1)
      ...> |> Enum.reduce(&Interval.sum/2)
      ...> |> Interval.name
      "7m"
  """
  def sum(
    %Interval{letter_distance: first_letter_distance, alteration: first_alteration},
    %Interval{letter_distance: second_letter_distance, alteration: second_alteration}
  ) do
    %Interval{
      letter_distance: first_letter_distance + second_letter_distance |> rem(7),
      alteration: first_alteration + second_alteration
    }
  end

  @doc """
      iex> Interval.from_notation("5P")
      ...> |> Interval.circle
      ...> |> Enum.map(&Interval.name/1)
      ["1P", "2M", "3M", "4P", "5P", "6M", "7M"]
  """
  def circle(interval = %Interval{}), do: circle(interval, [interval])
  def circle(interval = %Interval{}, intervals = [first | others]) do
    new_interval =
      intervals
      |> List.last
      |> Interval.sum(interval)

    should_continue =
      [first, new_interval]
      |> Enum.map(&Interval.semitones/1)
      |> Enum.reduce(& &1 !== &2)

    if should_continue do
      circle(interval, intervals ++ [new_interval])
    else
      intervals |> Enum.sort(& Interval.semitones(&1) < Interval.semitones(&2))
    end
  end

  @doc """
      iex> "2M" |> Interval.from_notation |> Interval.semitones
      2

      iex> "1A" |> Interval.from_notation |> Interval.semitones
      1

      iex> "3D" |> Interval.from_notation |> Interval.semitones
      3

      iex> "3M" |> Interval.from_notation |> Interval.semitones
      4

      iex> "4A" |> Interval.from_notation |> Interval.semitones
      6

      iex> %Interval{letter_distance: 8} |> Interval.semitones
      1
  """
  def semitones(%Interval{letter_distance: letter_distance, alteration: alteration}) do
    letter_semitones = Enum.at(@letter_distance_semitones, letter_distance)
    if letter_semitones do
      letter_semitones + alteration |> rem(12)
    else
      %Interval{
        letter_distance: letter_distance - 1,
        alteration: alteration + 1
      } |> semitones |> rem(12)
    end
  end
end
