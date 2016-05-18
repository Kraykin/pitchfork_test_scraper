# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

# require 'scraperwiki'
# require 'mechanize'
#
# agent = Mechanize.new
#
# # Read in a page
# page = agent.get("http://foo.com")
#
# # Find somehing on the page using css selectors
# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".

require 'nokogiri'
require 'open-uri'
require 'scraperwiki'

ScraperWiki.config = { db: 'data.sqlite', default_table_name: 'data' }

base_url = "http://pitchfork.com"
page = Nokogiri::HTML(open(base_url + "/reviews/albums"))

review_links = page.css(".album-link").map {|a| a['href']}

reviews = review_links.map do |link|
  review = Nokogiri::HTML(open(base_url + link))
  
  artist = review.css(".artist-list a").text
  album = review.css(".review-title").text
  label = review.css(".label-list li").text
  year = review.css(".year span+ span").text
  reviewer = review.css(".display-name").text
  review_date = Date.parse(review.css(".pub-date")[0]['title'])
  score = review.css(".score").text
  
  {
    artist: artist,
    album: album,
    label: label,
    year: year,
    reviewer: reviewer,
    review_date: review_date,
    score: score
  }
  
end

reviews.each do |review|
  ScraperWiki.save_sqlite([:artist, :album], review)
end