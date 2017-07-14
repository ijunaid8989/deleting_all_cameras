defmodule DelCam do
  require Logger
  @moduledoc """
  Documentation for DelCam.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DelCam.hello
      :world

  """
  def fetch_all_cameras_exids do
    with {:ok, response} <- HTTPoison.get("https://media.evercam.io/v1/cameras?api_id=2091d756&api_key=ea3f489a45c98eab5cc22e38db1071e8", [], hackney: []),
         %HTTPoison.Response{status_code: 200, body: body} <- response,
         {:ok, data} <- Poison.decode(body),
         true <- is_list(data["cameras"]) do
      Enum.map(data["cameras"], fn(item) -> item["id"] end)
    else
      _ -> []
    end
  end

  def delete_each_camera(camera_exid) do
    with {:ok, response} <- HTTPoison.delete("https://media.evercam.io/v1/cameras/#{camera_exid}?api_id=2091d756&api_key=ea3f489a45c98eab5cc22e38db1071e8", [], hackney: []),
         %HTTPoison.Response{status_code: 200, body: body} <- response
    do
      Logger.info "camera #{camera_exid} has been deleted from your account. [body: #{body}]"
    end
  end

  def do_all_together_now do
    Logger.info "Camera Deletion Has been started."
    DelCam.fetch_all_cameras_exids
    |> Enum.each(fn(camera_exid) ->
      Logger.info "Deleting Camera #{camera_exid}."
      DelCam.delete_each_camera(camera_exid)
      Logger.info "Going for the next one."
    end)
  end
end
