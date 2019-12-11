if Code.ensure_loaded?(Kadabra) do
  defmodule Pigeon.Http2.Client.Kadabra do
    @moduledoc false

    @behaviour Pigeon.Http2.Client

    def start do
      Application.ensure_all_started(:kadabra)
    end

    def connect(uri, scheme, opts) do
      host = "#{scheme}://#{uri}"
      Kadabra.open(host, ssl: opts)
    end

    def send_request(pid, headers, data, _state) do
      Kadabra.request(pid, headers: headers, body: data)
    end

    @doc ~S"""
    send_ping/1 implementation

    ## Examples

        iex> {:ok, pid} = Kadabra.open("https://http2.golang.org")
        iex> Pigeon.Http2.Client.Kadabra.send_ping(pid)
        :ok
    """
    def send_ping(pid, _state) do
      Kadabra.ping(pid)
      :ok
    end

    def handle_end_stream(_pid, {:end_stream, stream}, state) do
      %{id: id, status: status, headers: headers, body: body} = stream

      pigeon_stream = %Pigeon.Http2.Stream{
        id: id,
        status: status,
        headers: headers,
        body: body
      }

      {:ok, pigeon_stream, state}
    end

    def handle_end_stream(_pid, msg, _state) do
      msg
    end
  end
end
