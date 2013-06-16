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
page_text_items = Array.new()

pages_text.each do |page| 
  page_text_lines = page.split(/(\\n)|(\n)|[ \t]{2,}/i)
  page_text_lines.each do |line|
    page_text_items << line
  end
end

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

# Using a hash instead of an array to store this data before output to CSV,
# to make the code a bit more understandable
patco_schedule = Hash.new()

# Hard-coding Jan 1 2013 for lack of a better idea of what the start date should be
patco_schedule_start_date = 20130101
# ditto for the end date (Dec 31 2013)
patco_schedule_end_date = 20131231 

# Hard-code separate service calendars for the weekday, Saturday, and Sunday timetables
patco_schedule["weekday"] = Calendar.new([
  1, # service_id
  1, # Does this service run on Mondays?
  1, # Does this service run on Tuesdays?
  1, # Wednesdays?
  1, # Thursdays?
  1, # Fridays?
  0, # Saturdays?
  0, # Sundays?
  patco_schedule_start_date,
  patco_schedule_end_date
])
patco_schedule["saturday"] = Calendar.new([2, 0, 0, 0, 0, 0, 1, 0, patco_schedule_start_date, patco_schedule_end_date])
patco_schedule["sunday"] = Calendar.new([3, 0, 0, 0, 0, 0, 0, 1, patco_schedule_start_date, patco_schedule_end_date])

# Best guess for route_type was 2 - "Rail. Used for intercity or long-distance travel."
# https://developers.google.com/transit/gtfs/reference#routes_fields
# Also verified by looking up current PATCO designation on Google Maps. A "rail" icon is displayed.
patco_routes = Array.new()
patco_routes << Route.new([
  1, # route_id
  "PATCO", # route_short_name
  "PATCO Speedline", # route_long_name
  2 # route_type
])

# Pretty easy to get these. Parsing the PDF garbles the names pretty badly, so we're hard-coding them here.
patco_stop_names = ["Lindenwold", "Ashland", "Woodcrest", "Haddonfield", "Westmont", "Collingswood", "Ferry Avenue", "Broadway", "City Hall", "8th & Market St.", "9-10th & Locust St.", "12-13th & Locust St.", "15-16th & Locust St."]

# These were fetched via Google Maps. (http://productforums.google.com/forum/#!topic/maps/NqlDbTLlyjY)
patco_stop_coords = [[39.833817,-75.000318], [39.858957,-75.009505], [39.87019,-75.011222], [39.897358,-75.036818], [39.906922,-75.046559], [39.913324,-75.064884], [39.92296,-75.091898], [39.942589,-75.119224], [39.945657,-75.12106], [39.951143,-75.153567], [39.947319,-75.157624], [39.947944,-75.162345], [39.948635,-75.167774]]

patco_stops = Array.new(patco_stop_names.count) do |stop_id| # iterate through the number of stops
  Stop.new([
    stop_id, # Arbitrary int representing the stop
    patco_stop_names[stop_id], 
    patco_stop_coords[stop_id][0], # Latitude of stop
    patco_stop_coords[stop_id][1] # Longitude of stop
  ])
end

# More to come...
