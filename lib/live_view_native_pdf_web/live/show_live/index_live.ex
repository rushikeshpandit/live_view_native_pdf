defmodule LiveViewNativePdfWeb.ShowLive.IndexLive do
  use LiveViewNativePdfWeb, :live_view
  use LiveViewNativePdfNative, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, nil)
     |> allow_upload(:file_url, accept: ~w(.pdf), max_entries: 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :file_url, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :file_url, fn %{path: path}, entry ->
        [ext | _] = MIME.extensions(entry.client_type)

        dest =
          Path.join([
            :code.priv_dir(:live_view_native_pdf),
            "static",
            "upload_file",
            Path.basename(path <> "." <> ext)
          ])

        name = dest |> Path.basename()
        File.cp!(path, dest)
        {:ok, name}
      end)

    socket = socket |> assign(:uploaded_files, uploaded_files)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("previous_page", _param, socket) do
    IO.inspect("previous_page")
    {:noreply, push_event(socket, "prev", %{event: "prev"})}
  end

  @impl Phoenix.LiveView
  def handle_event("next_page", _param, socket) do
    IO.inspect("next_page")
    {:noreply, push_event(socket, "next", %{event: "next"})}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <form id="upload-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.file_url} />
      <button type="submit">Display PDF</button>
    </form>
    <div :if={!is_nil(@uploaded_files)}>
      <div class="flex justify-between w-full mt-2">
        <.button class="js-prev" type="button">Prev</.button>
        <input class="js-zoom" type="range" value="1.0" min="0" max="2" step=".1" />
        <.button class="js-next" type="button">Next</.button>
      </div>
      <canvas class="mt-1" phx-hook="PDF" id="pdf-canvas" data-path={@uploaded_files}></canvas>
    </div>
    <script src="//mozilla.github.io/pdf.js/build/pdf.mjs" type="module">
    </script>
    """
  end
end
