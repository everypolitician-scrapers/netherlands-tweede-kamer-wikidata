require 'wikidata/fetcher'

nl_names = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://nl.wikipedia.org/wiki/Samenstelling_Tweede_Kamer_2012-2017',
  after: '//h2[contains(.,"Gekozen bij de verkiezingen van 12 september 2012")]',
  before: '//span[@id="Bijzonderheden"]',
  xpath: './/li//a[not(@class="new")]/@title',
)

en_names = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://en.wikipedia.org/wiki/List_of_members_of_the_House_of_Representatives_of_the_Netherlands,_2012–17',
  after: '//h2[contains(.,"Parties")]',
  before: '//span[@id="References"]',
  xpath: './/li//a[not(@class="new")]/@title',
)

EveryPolitician::Wikidata.scrape_wikidata(names: { nl: nl_names, en: en_names })
