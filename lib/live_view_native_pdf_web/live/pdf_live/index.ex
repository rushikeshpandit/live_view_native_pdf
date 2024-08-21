defmodule LiveViewNativePdfWeb.PdfLive.Index do
  use LiveViewNativePdfWeb, :live_view
  alias LiveViewNativePdf.Products.Product
  alias LiveViewNativePdf.Products
  @upload_options [accept: ~w/.pdf/, max_entries: 1]

  def mount(_, _session, socket) do
    changeset = Products.change_product(%Product{})
    IO.inspect(changeset, label: "***** changeset from mount ")

    socket =
      socket
      |> assign(form: to_form(changeset))
      |> allow_upload(:image_url, @upload_options)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_params(params, _uri, socket) do
    IO.inspect(params, label: "***** params from handle_params ")

    changeset = Products.change_product(%Product{})
    IO.inspect(changeset, label: "***** changeset from handle_params ")

    {:ok,
     socket
     |> assign(form: to_form(changeset))
     |> allow_upload(:image_url, @upload_options)}

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    IO.inspect(product_params, label: "***** product_params from handle_event validate ")

    form =
      socket.assigns.product
      |> Products.change_product(product_params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("validate", _params, socket) do
    IO.inspect(socket, label: "***** socket from handle_event validate ")

    form =
      socket.assigns.product |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("cancel", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image_url, ref)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    IO.inspect(product_params, label: "***** product_params from handle_event save ")

    # consume_uploaded_entries(socket, :image_url, fn %{path: path}, entry ->
    #   file_name = get_file_name(entry)
    #   dest = Path.join("priv/static/uploads", file_name)
    #   {:ok, File.cp!(path, dest)}
    # end)

    {[image_url | _], []} = uploaded_entries(socket, :image_url)
    IO.inspect(image_url, label: "***** image_url ")
    #  image_url = ~p"/uploads/#{get_file_name(image_url)}"
    # product_params = Map.put(product_params, "image_url", image_url)
    {:noreply, socket}
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  defp get_file_name(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} id="products-form" phx-submit="save" phx-change="validate">
        <div class="container" phx-drop-target={@uploads.image_url.ref}>
          <.live_file_input upload={@uploads.image_url} /> or drag and drop
        </div>
        <div>
          Add up to <%= @uploads.image_url.max_entries %> photos
          (max <%= trunc(@uploads.image_url.max_file_size / 1_000_000) %> mb each)
        </div>

        <article
          :for={entry <- @uploads.image_url.entries}
          class="flex items-center justify-between"
          id={entry.ref}
        >
          <figure class="bg-orange-100 flex flex-col items-center justify-between rounded-md p-4">
            <.live_img_preview entry={entry} class="w-16 h-16" />
            <figcaption class="text-orange-800"><%= entry.client_name %></figcaption>
          </figure>
          <div class="flex flex-col w-full items-center p-8">
            <p
              :for={err <- upload_errors(@uploads.image_url, entry)}
              class="text-red-500 flex flex-col"
            >
              <%= error_to_string(err) %>
            </p>
            <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>
          </div>
          <button phx-click="cancel" phx-target={@myself} phx-value-ref={entry.ref}>
            <.icon name="hero-x-circle" class="h-6 w-6 text-orange-500 stroke-current" />
          </button>
        </article>
        <:actions>
          <.button phx-disable-with="Saving...">Open PDF</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
