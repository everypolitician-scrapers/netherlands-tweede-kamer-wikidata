require 'wikidata/fetcher'
require 'csv'
require 'combine_popolo_memberships'

WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'.freeze

def sparql(query)
  result = RestClient.get WIKIDATA_SPARQL_URL, { accept: 'text/csv', params: { query: query } }
  CSV.parse(result, headers: true, header_converters: :symbol)
rescue RestClient::Exception => e
  raise "Wikidata query #{query} failed: #{e.message}"
end

leg_mem_query = <<EOQ
  SELECT DISTINCT ?item ?itemLabel ?start_date ?end_date ?constituency ?constituencyLabel ?of ?ofLabel
  WHERE {
    ?item p:P39 ?statement .
    ?statement ps:P39 wd:Q18887908 .
    OPTIONAL { ?statement pq:P580 ?start_date }
    OPTIONAL { ?statement pq:P582 ?end_date }
    OPTIONAL { ?statement pq:P768 ?constituency }
    OPTIONAL { ?statement pq:P642 ?of }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
  }
  ORDER BY ?start_date
EOQ

pty_mem_query = <<EOQ
  SELECT DISTINCT ?item ?itemLabel ?party ?partyLabel ?start_date ?end_date
  WHERE {
    ?item wdt:P39 wd:Q18887908 .
    ?item p:P102 ?party_membership .
    ?party_membership ps:P102 ?party .
    OPTIONAL { ?party_membership pq:P580 ?start_date . }
    OPTIONAL { ?party_membership pq:P582 ?end_date . }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
  }
  ORDER BY ?itemLabel
EOQ

terms = [
  # { id: 11, start_date: '2010-06-09', end: '2012-09-12' },
  { id: 12, start_date: '2012-09-20' },
]

party_data = sparql(pty_mem_query).map(&:to_h).each do |r|
  r[:start_date] = r[:start_date].to_s[0..9]
  r[:end_date]   = r[:end_date].to_s[0..9]
  r[:end_date]   = '2012-09-19' if (r[:end_date] == '2012-09-20' && r[:start_date] < '2012-09-20')
  r[:id]         = r.delete :party
end

mem_data = sparql(leg_mem_query).reject { |r| r[:start_date].to_s.empty? && r[:end_date].to_s.empty? }.map(&:to_h).each do |r|
  r[:start_date] = r[:start_date].to_s[0..9]
  r[:end_date]   = r[:end_date].to_s[0..9]
  r[:end_date]   = '2012-09-19' if (r[:end_date] == '2012-09-20' && r[:start_date] < '2012-09-20')
end


mem_data.map { |mem| mem[:item] }.uniq.each do |q|
  leg_mems = mem_data.select { |mem| mem[:item] == q }
  party_mems = party_data.select { |mem| mem[:item] == q }

  term_12_mems = CombinePopoloMemberships.combine(term: terms, id: leg_mems)
  next if term_12_mems.empty?

  CombinePopoloMemberships.combine(id: term_12_mems, party: party_mems).each do |data|
    puts "%s,%s,%s,%s" % [data[:itemlabel], data[:partylabel], data[:start_date], data[:end_date]]
  end
end


