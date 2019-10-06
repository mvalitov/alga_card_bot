defmodule AlgaCard.Balance do
  require Logger

  def get(number) do
    case HTTPoison.post(
           "https://pay.brsc.ru/Alga.pay/GoldenCrownSite.php",
           "cardnumber=" <> prepare_card_number(number),
           req_headers()
         ) do
      {:ok, %HTTPoison.Response{status_code: 302, headers: headers} = response} ->
        Logger.debug(inspect(response))

        case get_sum_from_headers(headers) do
          {:ok, sum} ->
            {:ok, sum}

          {:error, reason} ->
            Logger.error(inspect(reason))
            {:error, reason}
        end

      {:error, error} ->
        Logger.error(inspect(error))
    end
  end

  def prepare_card_number(number) do
    String.slice(number, 0..3) <>
      "+" <>
      String.slice(number, 4..8) <>
      "+" <> String.slice(number, 9..13) <> "+" <> String.slice(number, 14..18)
  end

  def req_headers() do
    [
      {"content-type", "application/x-www-form-urlencoded"},
      {"user-agent",
       "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36"},
      {"accept",
       "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"}
    ]
  end

  def get_sum_from_headers(headers) do
    case Enum.find(headers, fn {k, _v} ->
           String.downcase(k) == "location"
         end) do
      {_k, url} ->
        # "http://algacard.ru/balance.php?allow=yes&sum=170"
        uri = URI.parse(url)

        case URI.decode_query(uri.query) do
          %{"allow" => "yes", "sum" => sum} -> {:ok, sum}
          %{"allow" => "no", "message" => msg} -> {:error, msg}
        end

      nil ->
        {:error, "Извините, сервис временно недоступен"}
    end
  end
end
