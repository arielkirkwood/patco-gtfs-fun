require 'csv'
require 'pdf-reader'
require 'require_all'
require 'pp'

require_all 'patco-gtfs-fun'

puts "Hello world!"
pages_text = Array.new()
timetable = Array.new()

File.open("files/timetable.pdf", "rb") do |file|
  reader = PDF::Reader.new(file)
  reader.pages.each do |page|
    pages_text << page.text
  end
end

# Feed our PDF text into an array, delimiting each item any time we 
# run into newline characters, whether actual new lines or instances of "\n"
# found in the document.
page_text_items = pages_text.split(/(\\n)|(\n)|[ \t]{2,}/i)

puts "Before Reject: #{page_text_items.count} items."

# Remove empty array items.
page_text_items = page_text_items.reject! { |item| item.empty? }

puts "After Reject: #{page_text_items.count} items."

# clean up whitespace (regex: /X?((20|21|22|23|[01]\d|\d)(([:.][0-5]\d){1,2}) [AP])|(——>)|(——)/)
page_text_items.each do |item|
  item.strip!
  # puts item
  item.match(/X?((20|21|22|23|[01]\d|\d)(([:.][0-5]\d){1,2}) [AP])/) { |match| 
    timetable << match
  }
end

# After, we remove empty lines from our array of text items
page_text_items.delete("")

puts "After Delete: #{page_text_items.count} items."

puts "#{timetable.count} timetable items"
puts "#{page_text_items.count} text items"

# Start putting together hard-coded data

# The sources of some data are pretty obvious, but here's a list of non-obvious sources of hard-coded data:
# http://en.wikipedia.org/wiki/PATCO_Speedline
# http://en.wikipedia.org/wiki/Delaware_River_Port_Authority

# Sources/examples of other GTFS data:
# SEPTA: http://www2.septa.org/developer/
# NJTransit: https://www.njtransit.com/developer
patco_agencies = Array.new()
patco_agencies << Agency.new(["Port Authority Transit Corporation", "http://www.ridepatco.org/", "America/New_York"])

# Best guess for route_type was "2", "Rail. Used for intercity or long-distance travel."
# https://developers.google.com/transit/gtfs/reference#routes_fields
# Also verified by looking up current PATCO designation on Google Maps. A "rail" icon is displayed.
patco_routes = Array.new()
patco_routes << Route.new([1, "PATCO", "PATCO Speedline", 2])

# Pretty easy to get these.
patco_stop_names = ["Lindenwold", "Ashland", "Woodcrest", "Haddonfield", "Westmont", "Collingswood", "Ferry Avenue", "Broadway", "City Hall", "8th - Market", "9-10th Locust", "12-13th Locust", "15-16th Locust"]
# These were fetched via Google Maps. (http://productforums.google.com/forum/#!topic/maps/NqlDbTLlyjY)
patco_stop_coords = [[39.833817,-75.000318], [39.858957,-75.009505], [39.87019,-75.011222], [39.897358,-75.036818], [39.906922,-75.046559], [39.913324,-75.064884], [39.92296,-75.091898], [39.942589,-75.119224], [39.945657,-75.12106], [39.951143,-75.153567], [39.947319,-75.157624], [39.947944,-75.162345], [39.948635,-75.167774]]
patco_stops = Array.new(patco_stop_names.count) { |stop_id| Stop.new([stop_id, patco_stop_names[stop_id], patco_stop_coords[stop_id][0], patco_stop_coords[stop_id][1]]) }

# More to come...
