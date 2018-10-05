defmodule Gnarl.Pick do
  use Ecto.Schema

  schema "picks" do
    field :picker, :string
    field :winner, :string
    field :slot, :integer
    field :lock, :boolean, default: false
    field :antilock, :boolean, default: false
    field :season, :integer
    field :week, :integer
    timestamps
  end

  def build(picker, winners, lock, antilock), do: build(picker, winners, lock, antilock, 1)
  defp build(_picker, [], _lock, _antilock, _slot), do: []
  defp build(picker, [winner | rest], lock, antilock, slot) do
    [
      %__MODULE__{picker: picker, winner: winner, slot: slot, lock: winner == lock, antilock: winner == antilock} |
      build(picker, rest, lock, antilock, slot + 1)
    ]
  end
end
