defmodule LiveViewNativePdf.Posts.Post do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :file_url, LiveViewNativePdf.Uploaders.FileUploaders.Type

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title])
    |> cast_attachments(attrs, [:file_url], allow_paths: true)
    |> validate_required([:title])
  end
end
