defmodule Gnarl.Pick do
  @enforce_keys [:picker, :winner, :slot]
  defstruct picker: '', winner: '', slot: 0, lock: false, antilock: false
end
