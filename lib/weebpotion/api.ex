defmodule WeebPotion.Api do
  alias WeebPotion.Struct.Image

  import WeebPotion.Requester
  import Poison

  def random_image!(client, opts \\ []) when (client !== nil and is_list(opts)) do
    link = "/random?type=#{opts[:type]}&nsfw=#{opts[:nsfw] || false}&hidden=#{opts[:hidden] || false}"
    filetype = opts[:filetype]
    if filetype !== :both, do: link <> "&filetype=#{filetype}"

    get!(link, client.auth_header, recv_timeout: 500).body
    |> decode!(as: %Image{})
  end

  def random_image(client, opts \\ []) when (client !== nil and is_list(opts)) do
    link = "/random?type=#{opts[:type]}&nsfw=#{opts[:nsfw] || false}&hidden=#{opts[:hidden] || false}"
    filetype = opts[:filetype]
    if filetype !== :both, do: link <> "&filetype=#{filetype}"

    {:ok, response} = get(link, client.auth_header, recv_timeout: 500)
    decode(response.body(), as: %Image{})
  end

  def image_info!(client, image_id) when (client !== nil and is_binary(image_id)) do
    link = "/info/#{image_id}"
    get!(link, client.auth_header, recv_timeout: 500).body
    |> decode!(as: %Image{})
  end

  def image_info(client, image_id) when (client !== nil and is_binary(image_id)) do
    link = "/info/#{image_id}"
    {:ok, response} = get(link, client.auth_header, recv_timeout: 500)
    decode(response.body(), as: %Image{})
  end

  def image_types(client, opts \\ []) when (client !== nil and is_list(opts)) do
    preview = opts[:preview] || false
    link = "/types?type=#{opts[:type]}&nsfw=#{opts[:nsfw] || false}&hidden=#{opts[:hidden] || false}&preview=#{preview}"
    {:ok, response} = get(link, client.auth_header, recv_timeout: 500)
    try do
      {:ok, body} = decode(response.body())
      if preview do
        {:ok, types} = Map.fetch(body, "types")
        {:ok, preview} = Map.fetch(body, "preview")
        types
        |> Enum.with_index
        |> Enum.map(&({elem(&1, 0), Enum.at(preview, elem(&1, 1))}))
      else
        {:ok, types} = Map.fetch(body, "types")
      end
    catch
      e in MatchError -> {:error, e}
    end
  end

  def image_types!(client, opts \\ []) when (client !== nil and is_list(opts)) do
    preview = opts[:preview] || false
    link = "/types?type=#{opts[:type]}&nsfw=#{opts[:nsfw] || false}&hidden=#{opts[:hidden] || false}&preview=#{preview}"
    {:ok, response} = get(link, client.auth_header, recv_timeout: 500)
    body = decode!(response.body())
    if preview do
      types = Map.fetch!(body, "types")
      preview = Map.fetch!(body, "preview")
      types
      |> Enum.with_index
      |> Enum.map(&({elem(&1, 0), Enum.at(preview, elem(&1, 1))}))
    else
      Map.fetch!(body, "types")
    end
  end
end