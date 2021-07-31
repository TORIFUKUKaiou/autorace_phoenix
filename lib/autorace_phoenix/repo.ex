defmodule AutoracePhoenix.Repo do
  use Ecto.Repo,
    otp_app: :autorace_phoenix,
    adapter: Ecto.Adapters.Postgres
end
