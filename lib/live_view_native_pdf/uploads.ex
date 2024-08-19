defmodule LiveViewNativePdf.Uploads do
  alias LiveViewNativePdf.Repo
  alias LiveViewNativePdf.Uploads.FileRef
  import Ecto.Query
  require Logger

  def thumb_format, do: "png"
  def thumb_x, do: 250
  def thumb_y, do: 250
  def upload_dir, do: Application.get_env(:live_view_native_pdf, :upload_dir)

  def get_full_upload_path(%FileRef{path: path, extension: extension}) do
    Path.join(upload_dir(), path) <> extension
  end

  def pdf?(%FileRef{} = file_ref) do
    String.downcase(file_ref.extension) == ".pdf"
  end

  def get_file_info(source_path, client_name) do
    try do
      # Throws when source_path isn't an image or doesn't exist.
      info = Mogrify.identify(source_path)
      format = String.downcase(info.format)

      if format == "pdf" do
        %{extension: ".pdf"}
      else
        %{
          extension: "." <> format,
          image_height: info.height,
          image_width: info.width
        }
      end
    rescue
      MatchError ->
        %{extension: Path.extname(client_name)}
    end
  end

  def hash_file!(source_path) do
    File.stream!(source_path)
    |> Enum.reduce(:crypto.hash_init(:sha), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
  end

  def get_relative_upload_path(dir, client_name) do
    Path.join([dir, FileRef.clean_path(client_name)])
  end

  defp cp!(source, dest) do
    File.mkdir_p!(Path.dirname(dest))
    File.cp!(source, dest)
  end

  defp write_upload!(%FileRef{} = file_ref, source_path) do
    try do
      cp!(source_path, get_full_upload_path(file_ref))
      file_ref
    rescue
      e ->
        Repo.delete!(file_ref)
        reraise(e, __STACKTRACE__)
    end
  end

  def make_upload_params(source_path, dir, client_name, client_size) do
    Map.merge(
      %{
        byte_size: client_size,
        sha_hash: hash_file!(source_path),
        path: get_relative_upload_path(dir, client_name)
      },
      get_file_info(source_path, client_name)
    )
  end

  defp get_or_create_file_upload(params) do
    existing_ref =
      FileRef
      |> where([ref], ref.sha_hash == ^params.sha_hash)
      |> Repo.one()

    case existing_ref do
      nil -> Repo.insert(FileRef.changeset(%FileRef{}, params))
      _ -> {:exists, existing_ref}
    end
  end

  defp save_file_ref(source_path, params) do
    case get_or_create_file_upload(params) do
      {:ok, file_ref} ->
        file_ref
        |> write_upload!(source_path)

      {:exists, file_ref} ->
        {:ok, file_ref}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def save_file_upload(source_path, params, model) do
    with {:ok, %FileRef{} = file_ref} <- save_file_ref(source_path, params) do
      {:ok, file_ref}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp set_file_name(file_ref) do
    Map.put(file_ref, :file_name, FileRef.name(file_ref))
  end

  def get_file_ref(id) do
    FileRef |> Repo.get(id) |> set_file_name()
  end

  def get_file_ref!(id) do
    FileRef |> Repo.get!(id) |> set_file_name()
  end

  def change_file_ref(%FileRef{} = file_ref, attrs \\ %{}) do
    FileRef.changeset(file_ref, attrs)
  end
end
