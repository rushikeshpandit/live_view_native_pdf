defmodule LiveViewNativePdfWeb.ShowLive.Index do
  use LiveViewNativePdfWeb, :live_view

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
end
