require 'rubygems'
require 'bundler/setup'

require 'liquid'
require 'json'

BASE_URL = 'http://egh.github.io/zotero-lookup-engines/'

# Hack
module TextFilter
  def amp_escape(input)
    input.gsub('&', '&amp;')
  end
end

Liquid::Template.register_filter(TextFilter)

html_template = Liquid::Template.parse(File.read('engine.liquid'))
index_template = Liquid::Template.parse(File.read('index.liquid'))
Liquid::Template.file_system = Liquid::LocalFileSystem.new(__dir__)

def fix_json(json)
  json['linkparams'] ||= []
  # Annoying, not sure how to do it better though
  json['linkparams'] = JSON.generate(json['linkparams'])
  json
end

# examples
crossref = fix_json(JSON.parse(File.read('engines_json/crossref.json')))
google = fix_json(JSON.parse(File.read('engines_json/google.json')))

us_states_map = JSON.parse(File.read('us_states.json'))
countries_map = JSON.parse(File.read('countries.json'))

items = Dir['engines_json/*'].map do |filename|
  item = fix_json(JSON.parse(File.read(filename)))
  filename = File.basename(filename, '.json')
  item['filename'] = filename
  country_code = (item['country'] || '').downcase
  item['region'] = us_states_map.fetch((item['region'] || '').downcase, nil) if country_code == 'us'
  item['country'] = countries_map.fetch(country_code, nil)
  item
end.sort_by do |i|
  i['title'].downcase
end

items.each do |item|
  filename = item['filename']
  File.open(File.join('generated', "#{filename}.html"), 'w') do |f|
    f << html_template.render('item' => item, 'crossref' => crossref, 'google' => google)
  end
end

File.open(File.join('generated', 'index.html'), 'w') do |f|
  f << index_template.render('items' => items)
end
