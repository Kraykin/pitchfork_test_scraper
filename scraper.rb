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
require 'sqlite3'

db = SQLite3::Database.new 'data.sqlite'
db.results_as_hash = true
db.execute 'CREATE  TABLE IF NOT EXISTS Data
    (
      "id" INTEGER PRIMARY KEY  AUTOINCREMENT  UNIQUE,
      artist TEXT,
      album TEXT,
      label TEXT,
      year TEXT,
      reviewer TEXT,
      review_date DATE,
      score TEXT
    )'

base_url = 'http://pitchfork.com'
pages_to_load = 10

pages_to_load.times do |n|
  page = Nokogiri::HTML(open(base_url + '/reviews/albums/?page=' + n.to_s))
  links_on_reviews = page.css('.album-link').map { |a| a['href'] }

  links_on_reviews.map do |link|
    review_page = Nokogiri::HTML(open(base_url + link))

    artist = review_page.css('.artist-list li').text
    album = review_page.css('.review-title').text
    label = review_page.css('.label-list li').text
    year = review_page.css('.year span+ span').text
    reviewer = review_page.css('.display-name').text
    review_date = Date.parse(review_page.css('.pub-date')[0]['title']).to_s
    score = review_page.css('.score').text

    db.execute 'INSERT INTO Data
      (
        artist,
        album,
        label,
        year,
        reviewer,
        review_date,
        score
      )
      VALUES ( ?, ?, ?, ?, ?, ?, ? )', [artist, album, label, year, reviewer, review_date, score]

    sleep(3.0 + rand * 2)
  end
end