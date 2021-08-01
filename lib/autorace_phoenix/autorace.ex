defmodule AutoracePhoenix.Autorace do
  @places [
    川口: "kawaguchi",
    伊勢崎: "isezaki",
    浜松: "hama",
    飯塚: "iizuka",
    鉄壁山陽: "sanyou"
  ]

  @races 1..12 |> Keyword.new(&{"#{&1}R" |> String.to_atom(), &1})

  def places, do: @places

  def races, do: @races

  def url(date, place, race) do
    # "http://sp-auto.digi-c.com/autorace/_definst_/kawaguchi/2020/kawaguchi_20201103_12/playlist.m3u8"
    "https://sp-auto.digi-c.com/autorace/_definst_/#{place}/#{date.year}/#{place}_#{
      Date.to_string(date) |> String.replace("-", "")
    }_#{Integer.to_string(race) |> String.pad_leading(2, "0")}/playlist.m3u8"
  end
end
