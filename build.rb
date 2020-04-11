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

html_template = Liquid::Template.parse(File.read('engine.html'))
index_template = Liquid::Template.parse(File.read('index.html'))

countries = {}
items = Dir['engines_json/*'].map do |filename|
  item = JSON.parse(File.read(filename))
  filename = File.basename(filename, '.json')
  item['filename'] = filename
  item
end.sort_by do |i|
  [i['country'] || '', i['state'] || '', i['filename']]
end

items.each do |item|
  filename = item['filename']
  country = item['country'] || 'NONE'
  state = item['state'] || 'NONE'
  countries[country] ||= {}
  countries[country][state] ||= []
  countries[country][state].push(item)
  File.open(File.join('generated', "#{filename}.html"), 'w') do |f|
    f << html_template.render('item' => item)
  end
end

File.open(File.join('generated', 'index.html'), 'w') do |f|
  f << index_template.render('countries' => countries)
end
