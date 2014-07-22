require 'json'

raw_data = JSON.parse(File.read(ARGV[0]))
items = {}
raw_data["items"].each do |i|
  md = i["title"].match(/^(\[(?:CA|AU)\] |DE: )?([A-Z][A-Z])?(?: - )?(.*)$/)
  country = if md[1] == "[CA] " then
              "CA"
            elsif md[1] == "[AU] " then
              "AU"
            elsif md[1] == "DE: " then
              "DE"
            elsif md[1].nil? then
              "US"
            else
              puts md[1]
            end
  state = md[2]
  title = md[3]
  items[i["name"].gsub(/\//, "_")] = { "country" => country,
                                       "state" => state,
                                       "title" => title,
                                       "linktemplate" => i["link"].gsub('#{ISBN}', "{rft:isbn}") }
end
   
items.each do |name, item|
  File.open(File.join("engines_json", "#{name}.json"), "w") do |f|
    f << JSON.pretty_generate(item)
  end
end
