defmodule Ie3c.Repo do
  use Ecto.Repo,
    otp_app: :ie3c,
    adapter: Ecto.Adapters.Postgres
end
