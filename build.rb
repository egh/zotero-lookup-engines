require 'rubygems'
require 'bundler/setup'

require 'liquid'
require 'json'

BASE_URL = 'http://www.e6h.org/tmp/engines/'

# Hack
module TextFilter
  def amp_escape(input)
    input.gsub('&', '&amp;')
  end
end

Liquid::Template.register_filter(TextFilter)

xml_template = Liquid::Template.parse(File.read('engine.xml'))
html_template = Liquid::Template.parse(File.read('engine.html'))
index_template = Liquid::Template.parse(File.read('index.html'))

countries = {}
items = Dir['engines_json/*'].map do |filename|
  item = JSON.parse(File.read(filename))
  name = File.basename(filename, '.json')
  item['xmlurl'] = "#{BASE_URL}#{name}.xml"
  item['name'] = name
  item
end.sort_by do |i|
  [i['country'] || '', i['state'] || '', i['title']]
end

items.each do |item|
  name = item['name']
  country = item['country'] || 'NONE'
  state = item['state'] || 'NONE'
  countries[country] ||= {}
  countries[country][state] ||= []
  countries[country][state].push(item)
  File.open(File.join('engines', "#{name}.xml"), 'w') do |f|
    f << xml_template.render('item' => item)
  end
  File.open(File.join('engines', "#{name}.html"), 'w') do |f|
    f << html_template.render('item' => item)
  end
end

File.open(File.join('engines', 'index.html'), 'w') do |f|
  f << index_template.render('countries' => countries)
end
