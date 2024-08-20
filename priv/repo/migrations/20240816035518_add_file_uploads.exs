defmodule Purple.Repo.Migrations.AddFileUploads do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :image_url, :string

      timestamps()
    end
  end
end
