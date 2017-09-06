defmodule HttpClient do
  def get(url) do
    %HTTPoison.Response{body: body} = HTTPoison.get! url

    {:ok, body}
  end
end
