defmodule LiveViewNativePdfWeb.PostLive.FormComponent do
  use LiveViewNativePdfWeb, :live_component

  alias LiveViewNativePdf.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.live_file_input upload={@uploads[:file_url]} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  """
  2. Allow the upload of files, specify the allowed extensions and define the name of the attribute in which the file is going
     to be stored inside the "uploads" assign.
  """

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:file_url, accept: ~w(.pdf))}
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Posts.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(changeset)
     end)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset = Posts.change_post(socket.assigns.post, post_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  """
  3. Consume the uploaded file and add it to the changeset to be handled by Waffle
  """

  def handle_event("save", %{"post" => post_params}, socket) do
    [file_path] =
      consume_uploaded_entries(socket, :file_url, fn %{path: path}, entry ->
        # Add the file extension to the temp file
        [ext | _] = MIME.extensions(entry.client_type)

        path_with_extension =
          path <> String.replace(entry.client_type, "application/pdf", ".") <> ext

        File.cp!(path, path_with_extension)
        {:ok, path_with_extension}
      end)

    save_post(socket, socket.assigns.action, Map.put(post_params, "file_url", file_path))
  end

  defp save_post(socket, :edit, post_params) do
    case Posts.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Posts.create_post(post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
