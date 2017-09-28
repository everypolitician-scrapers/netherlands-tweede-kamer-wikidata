require 'wikidata/fetcher'

nl_2017 = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://nl.wikipedia.org/wiki/Samenstelling_Tweede_Kamer_2017-heden',
  after: '//h2[contains(.,"Samenstelling van de Kamer")]',
  before: '//h2[contains(.,"Wijzigingen")]',
  xpath: './/li//a[not(@class="new")]/@title',
)

nl_2012 = EveryPolitician::Wikidata.wikipedia_xpath(
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

# Find all Memberships starting since the start of the 2012 Legislature
# This will ignore anyone who has a continuous membership from before
# that, but at the minute it's just a fallback for people missing from
# the lists above.
sparq = <<EOS
  SELECT DISTINCT ?item WHERE {
    ?item p:P39 ?position_statement .
    ?position_statement ps:P39 wd:Q18887908 ;
                        pq:P580 ?start_date .
    FILTER (?start_date >= "2012-09-01T00:00:00Z"^^xsd:dateTime) .
  }
EOS
p39s = EveryPolitician::Wikidata.sparql(sparq)

EveryPolitician::Wikidata.scrape_wikidata(ids: p39s, names: { nl: nl_2012 | nl_2017, en: en_names })
