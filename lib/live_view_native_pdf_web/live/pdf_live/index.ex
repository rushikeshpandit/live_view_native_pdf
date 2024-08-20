defmodule LiveViewNativePdfWeb.PdfLive.Index do
  alias LiveViewNativePdfWeb.PdfLive.ShowItem
  use LiveViewNativePdfWeb, :live_view
  alias LiveViewNativePdf.Products
  alias LiveViewNativePdf.Products.Product

  def handle_params(params, _uri, socket) do

    socket =
      socket
      |> apply_action(:new, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :new, _params) do
    socket |> assign(:page_title, "New Product") |> assign(:product, %Product{})
  end

  def render(assigns) do
    ~H"""
    <.live_component
      module={ShowItem}
      id={:new}
      product={@product}
      action={@live_action}
      navigate={~p"/show"}
    />
    """
  end
end
