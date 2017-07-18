defmodule Astarte.Housekeeping.API.Realms.Realm do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:realm_name]

  embedded_schema do
    field :realm_name
  end

  def changeset(realm, params \\ %{}) do
    realm
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:realm_name, ~r/^[a-z][a-z0-9]*$/)
  end
end
