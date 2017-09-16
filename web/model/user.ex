defmodule Flatfoot.User do
  use Flatfoot.Web, :model

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :username, :string
    field :global_threshold, :integer, default: 0
    has_many :sessions, Flatfoot.Session, on_delete: :delete_all
    has_many :notification_records, Flatfoot.NotificationRecord, on_delete: :delete_all
    has_many :blackout_options, Flatfoot.BlackoutOption, on_delete: :delete_all

    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username), [])
    |> validate_length(:username, min: 1, max: 20)
    |> validate_length(:name, min: 1, max: 50)
    |> unique_constraint(:username)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash
  end

  def put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
