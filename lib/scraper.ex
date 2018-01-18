defmodule Scraper do
	def get_image_source_manga_panda(src) do
		HTTPoison.get!(src).body
		|> Floki.find("div#imgholder")
		|> Floki.find("img")
		|> Floki.attribute("src")
		|> HTTPoison.get!
	end

	def get_manga_list do
		HTTPoison.get!("http://www.mangapanda.com/alphabetical").body
		|> Floki.find("ul.series_alpha")
		|> Floki.find("li a")
		|> Enum.map(fn {_tag, [{"href", location}], [title]} -> {location, title}  end)
	end

	def save_image(src, path) do
		full_path =
			Map.get(src, :headers)
			|> Enum.filter(fn {header, _value} -> String.match?(header, ~r/Content-Type/) end)
			|> Enum.map(fn {_header, value}  -> create_path(path, value) end)

		case File.open(full_path, [:write]) do
			{:ok, file} ->
				IO.binwrite(file, Map.get(src, :body))
				File.close(file)
			{:error, error} ->
				IO.puts "Error #{error}"
		end
	end


	defp create_path(path, string) do
		"image/" <> extension = string
		path <> "." <> extension
	end
end
