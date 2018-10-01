defmodule Gnarl.Pick do
  @enforce_keys [:picker, :winner, :slot]
  defstruct picker: '', winner: '', slot: 0, lock: false, antilock: false

  def build(picker, winners, lock, antilock), do: build(picker, winners, lock, antilock, 1)
  defp build(_picker, [], _lock, _antilock, _slot), do: []
  defp build(picker, [winner | rest], lock, antilock, slot) do
    [
      %__MODULE__{picker: picker, winner: winner, slot: slot, lock: winner == lock, antilock: winner == antilock} |
      build(picker, rest, lock, antilock, slot + 1)
    ]
  end
end
