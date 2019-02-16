defmodule Coltrane.Theory.Note do
  @moduledoc """
  Notes are different ways to classify and relate sounds.
  """

  alias Coltrane.Theory.{Interval, Note, PitchClass}

  @letters [
    "C",
    nil,
    "D",
    nil,
    "E",
    "F",
    nil,
    "G",
    nil,
    "A",
    nil,
    "B"
  ]

  @alterations %{"b" => -1, "#" => +1}

  @enforce_keys [:base_pitch_class]

  defstruct base_pitch_class: nil, alteration: 0

  @doc """
  Parses the notation into a Note struct

  ## Examples
      iex> Note.from_notation("C#")
      %Note{alteration: 1, base_pitch_class: 0}

      iex> Note.from_notation("D")
      %Note{alteration: 0, base_pitch_class: 2}

      iex> Note.from_notation("Ebb")
      %Note{alteration: -2, base_pitch_class: 4}
  """
  def from_notation(notation) do
    {letter, alteration_symbols} = String.split_at(notation, 1)

    %Note{
      base_pitch_class: Enum.find_index(@letters, &(&1 == letter)),
      alteration: alteration_from_notation(alteration_symbols)
    }
  end

  @doc """
      iex> Note.alteration_from_notation("##")
      2

      iex> Note.alteration_from_notation("bb")
      -2
  """
  def alteration_from_notation(""), do: 0

  def alteration_from_notation(symbols) do
    String.graphemes(symbols)
    |> Enum.map(&Map.get(@alterations, &1))
    |> Enum.reduce(&Kernel.+/2)
  end

  @doc """
      iex> Note.name(%Note{alteration: 2, base_pitch_class: 0})
      "C##"

      iex> Note.name(%Note{alteration: -1, base_pitch_class: 2})
      "Db"

      iex> Note.name(%Note{alteration: 0, base_pitch_class: 4})
      "E"

      iex> Note.name(%Note{alteration: 0, base_pitch_class: 1})
      "C#"

      iex> Note.name(%Note{alteration: 0, base_pitch_class: 6})
      "F#"
  """
  def name(%Note{alteration: alteration, base_pitch_class: base_pitch_class}) do
    letter = Enum.at(@letters, rem(base_pitch_class, length(@letters)))

    letter
    |> Kernel.&&(letter <> alteration_from_number(alteration))
    |> Kernel.||(name(%Note{alteration: alteration + 1, base_pitch_class: base_pitch_class - 1}))
  end

  @doc """
  Transposes a note by a certain interval

  ## Examples:
      iex> Note.transpose("C", "2M") |> Note.name
      "D"

      iex> Note.transpose("C", "2m") |> Note.name
      "Db"

      iex> Note.transpose("C", "1A") |> Note.name
      "C#"

      iex> Note.transpose("C#", "3M") |> Note.name
      "E#"

      iex> Note.transpose("C#", "1A") |> Note.name
      "C##"

      iex> Note.transpose("C##", "1A") |> Note.name
      "C###"

      iex> Note.transpose("C#", "5P") |> Note.name
      "G#"

      iex> Note.transpose(
      ...>   %Note{base_pitch_class: 1, alteration: 0},
      ...>   %Interval{letter_distance: 2, alteration: 0}
      ...> )
      %Note{base_pitch_class: 4, alteration: 1}

      iex> Note.transpose(
      ...>   %Note{base_pitch_class: 3, alteration: 0},
      ...>   %Interval{letter_distance: 0, alteration: 1}
      ...> )
      %Note{base_pitch_class: 2, alteration: 2}
  """
  def transpose(
        note = %Note{
          base_pitch_class: pitch_class,
          alteration: note_alteration
        },
        interval = %Interval{
          letter_distance: letter_distance,
          alteration: interval_alteration
        }
      ) do

    note_letter = letter(note)

    new_pitch_class =
      Enum.find_index(letters(), & &1 == note_letter)
      |> Kernel.+(letter_distance)
      |> (& Enum.at(letters(), &1 |> rem(letters() |> length))).()
      |> Note.from_notation
      |> PitchClass.from_note

    target_pitch_class =
      PitchClass.from_note(note) + Interval.semitones(interval)
      |> Kernel.rem(@letters |> length)

    new_alteration = target_pitch_class - new_pitch_class |> fix_alteration
    %Note{base_pitch_class: new_pitch_class, alteration: new_alteration}
  end

  defp fix_alteration(alteration) when alteration > 6,  do: alteration - 12
  defp fix_alteration(alteration) when alteration < -6, do: alteration + 12
  defp fix_alteration(alteration), do: alteration

  def transpose(note, interval = %Interval{}) do
    transpose(note |> Note.from_notation, interval)
  end

  def transpose(note, interval_notation) do
    transpose(
      note |> Note.from_notation,
      interval_notation |> Interval.from_notation
    )
  end

  @doc """
  Returns the symbol string part of a Note notation from a number.

  Examples:
      iex> Note.alteration_from_number(-2)
      "bb"

      iex> Note.alteration_from_number(2)
      "##"

      iex> Note.alteration_from_number(0)
      ""
  """
  def alteration_from_number(0), do: ""

  def alteration_from_number(alteration) do
    v = (alteration > 0 && +1) || -1

    Enum.find(@alterations, fn {_key, value} -> value == v end)
    |> elem(0)
    |> String.duplicate(abs(alteration))
  end

  def letter(note = %Note{}), do: name(note) |> String.split_at(1) |> elem(0)

  @doc """
  Returns all the letters used to describe music in western music

  Examples
      iex> Note.letters
      ["C", "D", "E", "F", "G", "A", "B"]
  """
  def letters, do: @letters |> Enum.filter(&(!is_nil(&1)))
end
