defmodule Coltrane.Theory.PitchClass do
  @moduledoc """
  Pitch classes are all the classes of pitches (frequencies) that are in a whole number of
  octaves apart.

  For example, C1, C2, C3 are all pitches from the C pitch class.
  """

  alias Coltrane.Theory.{PitchClass, Frequency, Note}

  @base_pitch_integer 9
  @base_tuning 440

  @doc """
  Returns the fundamental frequency of this pitch class

  ## Examples:
      iex> PitchClass.fundamental_frequency(0)
      16.351597831287414

      iex> Coltrane.Theory.PitchClass.fundamental_frequency(1)
      17.323914436054505
  """
  def fundamental_frequency(pitch_class) do
    Frequency.shift_octave(@base_tuning, -4) *
      :math.pow(2, (pitch_class - @base_pitch_integer) / 12)
  end

  @doc """
      iex> "C#" |> Note.from_notation |> PitchClass.from_note
      1

      iex> "Eb" |> Note.from_notation |> PitchClass.from_note
      3
  """
  def from_note(%Note{alteration: alteration, base_pitch_class: base_pitch_class}) do
    alteration + base_pitch_class
  end

  @doc """
  Gets the name of this pitch class in a note format

  ## Examples
      iex> PitchClass.name(1)
      "C#"
  """
  def name(pitch_class), do: PitchClass.note(pitch_class) |> Note.name()

  @doc """
  Gets the basic note representation of this pitch class

  ## Examples
      iex> PitchClass.note(1)
      %Note{base_pitch_class: 1}
  """
  def note(pitch_class), do: %Note{base_pitch_class: pitch_class}
end
