defmodule LiveViewNativePdfWeb.PostLive.Show do
  use LiveViewNativePdfWeb, :live_view

  alias LiveViewNativePdf.Posts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    post = Posts.get_post!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, post)
     |> assign(:post_file_url, get_post_file_url(post))}
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"

  defp get_post_file_url(post),
    do: LiveViewNativePdf.Uploaders.FileUploaders.url({post.file_url, post})
end
