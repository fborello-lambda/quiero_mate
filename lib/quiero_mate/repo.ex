defmodule QuieroMate.Repo do
  use Ecto.Repo,
    otp_app: :quiero_mate,
    adapter: Ecto.Adapters.SQLite3
end
