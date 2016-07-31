require 'wikidata/fetcher'

nl_names = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://nl.wikipedia.org/wiki/Samenstelling_Tweede_Kamer_2012-heden',
  after: '//h2[contains(.,"Samenstelling van")]',
  before: '//span[@id="Bijzonderheden"]',
  xpath: './/li//a[not(@class="new")]/@title',
)

en_names = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://en.wikipedia.org/wiki/Members_of_the_House_of_Representatives_of_the_Netherlands,_2012%E2%80%93present',
  after: '//h2[contains(.,"Parties")]',
  before: '//span[@id="References"]',
  xpath: './/li//a[not(@class="new")]/@title',
)

EveryPolitician::Wikidata.scrape_wikidata(names: { nl: nl_names, en: en_names })
