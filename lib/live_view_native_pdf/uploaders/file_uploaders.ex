defmodule LiveViewNativePdf.Uploaders.FileUploaders do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @allowed_extensions ~w(.pdf)

  def filename(version, {file, post}) do
    file_name = Path.basename(file.file_name, Path.extname(file.file_name))
    "_#{version}_#{file_name}"
  end

  def validate(_version, {file, _scope}) do
    file_extension =
      file.file_name
      |> Path.extname()
      |> String.downcase()

    Enum.member?(@allowed_extensions, file_extension)
  end
end
