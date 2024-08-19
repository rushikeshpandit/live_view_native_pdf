
defmodule LiveViewNativePdfWeb.PdfLive.ShowItem do
  alias LiveViewNativePdf.Uploads
  alias LiveViewNativePdf.Uploads.FileRef
  use LiveViewNativePdfWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="m-2 p-2">
        <.live_component
          accept={:any}
          dir={"transaction/123"}
          id={"transaction-123-upload"}
          max_entries={20}
          model={@transaction}
          module={LiveViewNativePdfWeb.LiveUpload}
          return_to={~p"/upload"}
        />
      </div>
    <.render_file_ref />
    """
  end

end
