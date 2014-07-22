require 'liquid'
require 'json'

BASE_URL="http://www.e6h.org/tmp/engines/"

module TextFilter
  def amp_escape(input)
    return input.gsub("&", "&amp;")
  end
end

Liquid::Template.register_filter(TextFilter)

xml_template = Liquid::Template.parse(File.read("engine.xml"))
html_template = Liquid::Template.parse(File.read("engine.html"))
index_template = Liquid::Template.parse(File.read("index.html"))

items = {}
Dir["engines_json/*"].each do |filename|
  item = JSON.parse(File.read(filename))
  name = File.basename(filename, ".json")
  country = item['country'] || "NONE"
  state = item['state'] || "NONE"
  items[country] ||= {}
  items[country][state] ||= []
  items[country][state].push(item)
  item['xmlurl'] = "#{BASE_URL}#{name}.xml"
  item['name'] = name
  File.open(File.join("engines", "#{name}.xml"), "w") do |f|
    f << xml_template.render('item' => item)
  end
  File.open(File.join("engines", "#{name}.html"), "w") do |f|
    f << html_template.render('item' => item)
  end
end

File.open(File.join("engines", "index.html"), "w") do |f|
  f << index_template.render('items' => items)
end
