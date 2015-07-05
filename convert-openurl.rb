# coding: utf-8
require 'json'
require 'active_support/inflector'

# import from https://www.zotero.org/support/locate/openurl_resolvers
ARGF.map do |line|
  name, url = *line.split(/\|/).delete_if { |s| s == '' }.compact.map { |s| s.strip.gsub(/\s+/, ' ') }
  {name: name, url: url}
end.each do |d|
  # strip accents
  safe_name = d[:name].gsub(/\s+/, '_').gsub(/,'/, '').downcase
  safe_name = safe_name.mb_chars.normalize(:kd).gsub(/[^x00-\x7F]/n, '').to_s
  linktemplate = if d[:url].match(/\?/)
                   "#{d[:url]}&{z:openURL}"
                 else
                   "#{d[:url]}?{z:openURL}"
                 end
  item = {
    'title' => d[:name],
    'name' => safe_name,
    'linktemplate' => linktemplate
  }
  File.open("engines_json/#{safe_name}.json", 'w') do |f|
    f << JSON.pretty_generate(item)
  end
end
