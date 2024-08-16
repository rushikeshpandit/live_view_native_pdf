defmodule LiveViewNativePdf.Repo do
  use Ecto.Repo,
    otp_app: :live_view_native_pdf,
    adapter: Ecto.Adapters.Postgres
end
