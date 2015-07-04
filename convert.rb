require 'json'
require 'open-uri'

BASE_URL = 'http://bookburrito-db.appspot.com/library/search'
AT_ONCE = 1000
# Hack, max 4000 libraries
TIMES = 3
items = {}
(0..TIMES).each do |i|
  url = "#{BASE_URL}?limit=#{AT_ONCE}&offset=#{i * AT_ONCE}"
  puts "Fetching #{url}..."
  raw_data = JSON.parse(open(url).read)
  raw_data['items'].each do |raw_item|
    md = raw_item['title'].match(/^(\[(?:CA|AU)\] |DE: )?([A-Z][A-Z])?(?: - )?(.*)$/)
    country = if md[1] == '[CA] '
                'CA'
              elsif md[1] == '[AU] '
                'AU'
              elsif md[1] == 'DE: '
                'DE'
              elsif md[1].nil?
                'US'
              else
                puts md[1]
              end
    state = md[2]
    title = md[3]
    items[raw_item['name'].gsub(/\//, '_')] = raw_item.merge('country' => country,
                                                             'state' => state,
                                                             'title' => title,
                                                             'linktemplate' => raw_item['link'].gsub('#{ISBN}', '{rft:isbn}'))
                                              .delete_if { |k| k == 'link' }
  end
end

items.each do |name, item|
  File.open(File.join('engines_json', "#{name}.json"), 'w') do |f|
    f << JSON.pretty_generate(item)
  end
end
