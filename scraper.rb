require 'open-uri'
require 'nokogiri'
require 'yaml'

### top chart and a single movie HTML files are downloaded
file = 'imdb_top.html'

html_as_a_string = open(file).read
html_doc = Nokogiri::HTML(html_as_a_string)

def fetch_movie_urls(html_doc)
  urls_array = []
  html_doc.search(".titleColumn a").first(5).each do |element|
    urls_array << element.attribute("href").value
  end
  return urls_array
end


def scrape_movie_info(html_doc)
  movie_hash = {}
  arr_of_chars = html_doc.search(".title_wrapper h1").text.strip.split("(").first.split("")
  arr_of_chars.pop
  movie_hash[:name] = arr_of_chars.join("")
  movie_hash[:year] = html_doc.search("#titleYear a").text.strip
  movie_hash[:summary] = html_doc.search(".summary_text").text.strip
  movie_hash[:director] = html_doc.search(".credit_summary_item a").first.text.strip
  return movie_hash
end

master_array = []
urls_array = fetch_movie_urls(html_doc)
urls_array.each do |url|
  html_as_a_string = open("https://www.imdb.com/#{url}").read
  html_doc = Nokogiri::HTML(html_as_a_string)
  master_array << scrape_movie_info(html_doc)
end


def write_movies_to_yaml(array_of_movie_hashes)
  File.open("movies.yml", 'wb') do |file|
    file.write(array_of_movie_hashes.to_yaml)
  end
end
write_movies_to_yaml(master_array)
