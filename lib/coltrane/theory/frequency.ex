defmodule Coltrane.Theory.Frequency do
  @moduledoc """
  Frequencies measure an relatively constant rate of oscilation of an elastic object,
  be it a string, drum or air.
  """

  @doc """
  This function changes the octave of a frequency

  ## Examples
      iex> Frequency.shift_octave(110, 1)
      220.0

      iex> Frequency.shift_octave(110, 2)
      440.0

      iex> Frequency.shift_octave(440, -4)
      27.5
  """
  def shift_octave(frequency, ammount) do
    frequency * :math.pow(2, ammount)
  end
end
