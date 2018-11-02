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
    try do
      {:ok, response} = get(link, client.auth_header, recv_timeout: 500)
      {:ok, image} = decode(response.body(), as: %Image{})
    catch
      e -> {:error, e}
    end
  end

  def image_info!(client, image_id) when (client !== nil and is_binary(image_id)) do
    link = "/info/#{image_id}"
    get!(link, client.auth_header, recv_timeout: 500).body
    |> decode!(as: %Image{})
  end

  def image_info(client, image_id) when (client !== nil and is_binary(image_id)) do
    link = "/info/#{image_id}"
    try do
        {:ok, response} = get(link, client.auth_header, recv_timeout: 500)
        {:ok, image} = decode(response.body(), as: %Image{})
    catch
      e -> {:error, e}
    end
  end

  def image_types(client, opts \\ []) when (client !== nil and is_list(opts)) do
    preview = opts[:preview] || false
    link = "/types?type=#{opts[:type]}&nsfw=#{opts[:nsfw] || false}&hidden=#{opts[:hidden] || false}&preview=#{preview}"
    try do
      {:ok, response} = get(link, client.auth_header, recv_timeout: 500)
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
      e -> {:error, e}
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

  def image_tags(client, opts \\ []) when (client !== nil and is_list(opts)) do
    link = "/tags?hidden=#{opts[:hidden] || false}&nsfw=#{opts[:nsfw] || false}"
    try do
      {:ok, response} = get(link, client.auth_header, recv_timeout: 500)
      {:ok, body} = decode(response.body())
      {:ok, tags} = Map.fetch(body, "tags")
    catch
      e -> {:error, e}
    end
  end

  def image_tags!(client, opts \\ []) when (client !== nil and is_list(opts)) do
    link = "/tags?hidden=#{opts[:hidden] || false}&nsfw=#{opts[:nsfw] || false}"
    get!(link, client.auth_header, recv_timeout: 500).body()
    |> decode!()
    |> Map.fetch!("tags")
  end

  def delete_image(client, image_id) when (client !== nil and is_binary(image_id)) do
    link = "/info/#{image_id}"
    try do
      {:ok, response} = delete(link, client.auth_header, recv_timeout: 500)
    catch
      e -> {:error, e}
    end
  end

  def delete_image!(client, image_id) when (client !== nil and is_binary(image_id)) do
    link = "/info/#{image_id}"
    delete!(link, client.auth_header, recv_timeout: 500)
  end

  def list_images(client, account_id \\ nil) when (client !== nil) do
    if account_id !== nil do
      if !is_binary(account_id) do
        {:error, :not_a_binary}
      else
        try do
          {:ok, response} = get("/list/#{account_id}")
          {:ok, body} = decode(response.body())
        catch
          e -> {:error, e}
        end
      end
    else
      try do
        {:ok, response} = get("/list")
        {:ok, body} = decode(response.body())
      catch
        e -> {:error, e}
      end
    end
  end

  def list_images!(client, account_id \\ nil) when (client !== nil) do
    if account_id !== nil do
      if !is_binary(account_id) do
        raise "not a binary!"
      end
      get!("/list/#{account_id}").body()
      |> decode!()
    else
      get!("/list").body()
      |> decode!()
    end
  end
end