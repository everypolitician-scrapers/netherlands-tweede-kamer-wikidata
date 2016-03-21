require 'bundler/setup'
require 'wikidata/fetcher'
names = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://nl.wikipedia.org/wiki/Samenstelling_Tweede_Kamer_2012-heden',
  after: '//h2[contains(.,"Samenstelling van")]',
  before: '//span[@id="Bijzonderheden"]',
  xpath: './/li//a[not(@class="new")]/@title',
)
EveryPolitician::Wikidata.scrape_wikidata(names: { nl: names })
