defmodule LiveViewNativePdf.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveViewNativePdf.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        file_url: "some file_url",
        title: "some title"
      })
      |> LiveViewNativePdf.Posts.create_post()

    post
  end
end
