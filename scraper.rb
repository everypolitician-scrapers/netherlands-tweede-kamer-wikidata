require 'bundler/setup'

require 'scraperwiki'
require 'wikidata/fetcher'
require 'nokogiri'
require 'open-uri/cached'
require 'rest-client'
require 'pry'

OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(URI.escape(URI.unescape(url))).read)
end

def wikinames_from(url)
  noko = noko_for(url)
  names = noko.xpath('//div[@id="mw-content-text"]//h3/following-sibling::div[@class="editmode"]/ul//a[contains(@href, "/wiki/") and not(@class="new")]/@title').map(&:text)
  abort 'No names' if names.count.zero?
  names
end

def fetch_info(names)
  WikiData.ids_from_pages('nl', names).each do |name, id|
    puts "Fetching #{name} #{id}"
    data = WikiData::Fetcher.new(id: id).data('nl')
    unless data
      warn "No data for #{name} #{id}"
      next
    end
    data[:original_wikiname] = name
    ScraperWiki.save_sqlite([:id], data)
  end
end

names = wikinames_from('https://nl.wikipedia.org/wiki/Samenstelling_Tweede_Kamer_2012-heden')

fetch_info names.uniq

warn RestClient.post(ENV['MORPH_REBUILDER_URL'], {}) if ENV['MORPH_REBUILDER_URL']
