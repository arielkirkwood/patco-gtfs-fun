require 'csv'
require 'pdf-reader'
require 'require_all'
require 'pp'
require 'time'

require_all 'patco-gtfs-fun'

puts "Hello world!"
pages_text = Array.new()

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

# Remove empty array items.
page_text_items = page_text_items.reject! { |item| item.empty? }

# First, we need a place to put our timetable-related items:
timetable_items = Array.new()

# clean up whitespace and collect timetable items into an array
page_text_items.each do |item|
  # Strip leading and trailing whitespace from the line
  item.strip!
  # p item

  # Our massive regex string finds the following matches:
  # A timestamp, optionally including special PATCO codes ("X" or "W"):
  # "12:30pm" (matched)
  # "X7:30am" (matched)
  # 
  # An arrow, indicating that a stop gets skipped:
  # "-->"
  # 
  # Empty strings also get matched:
  # ""
  # 
  # Here's how we break it down:
  # The first part looks for (and captures) the presence of an "X" or "W" character before the timestamp.
  # These represent special situations for a PATCO train. (for this version, we are not doing anything about it.)
  # It's optional (due to the "?" afterwards), but if there is one, the parentheses tell our 
  # match() function to make that character available in a portion of the result.
  # /([XW])? 
  # ** This part is not included in the current version of the regex because there was not enough time 
  # ** to write code tohandle these kinds of cases.
  # 
  # Next, we capture the timestamp itself.
  # The first part is looking for a number starting with a 0 or 1, and ending in any digit.
  # This way, we can catch 1, 2, 3, up to 12 (though it will capture numbers up to 19).
  # (([01]\d|\d)
  # 
  # Then, we look for the colon:
  # [:]
  # 
  # Now, the minutes. 
  # ([0-5]\d) <-- a number from 0-5 succeeded by any digit
  # 
  # This last part simply says that the result of the minutes may be 1 or 2 characters long.
  # {1,2}) 
  # 
  # Next, we get the "AM" or "PM" portion of the timestamp.
  #  ([AP])) <-- note the extra space character before the parentheses, it's important!
  # The second right parenthesis closes a capture block that captures the whole timestamp.
  # 
  # Sometimes, instead of a timestamp, we get an arrow (-->) with varying numbers of dashes representing that
  # the stop gets skipped on this trip. Since the characters include unicode em-dashes, the \u signals 
  # the regex to look for a unicode character at location # 2014. The "+" indicates that there may be more
  # than one dash.
  # For fun, I decided to include the unicode reference for ">" as well. (# 003E)
  # 
  # | <-- the pipe signifies an "or" case; we might get a timestamp, OR an arrow.
  # (\u2014+\u003E?)
  # 
  # To be more able to distinguish where the timetable switches to the other direction
  # (switching from the 13 "Westbound to Philadelphia" timestamps to the "Eastbound to Lindenwold" ones),
  # we include another "or" pipe with nothing on the other side. This lets blank lines through.
  # The final "/" indicates the end of the regex string.
  # |/
  item.match(/([XW])?((([01]\d|\d)[:.]([0-5]\d){1,2}) ([AP]))|(\u2014+\u003E?)|/) do |match| 
    timetable_items << match
  end
end


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
patco_schedule = Array.new()

# Hard-coding Jan 1 2013 for lack of a better idea of what the start date should be
patco_schedule_start_date = 20130101
# ditto for the end date (Dec 31 2013)
patco_schedule_end_date = 20131231 

# Hard-code separate service calendars for the weekday, Saturday, and Sunday timetables
patco_schedule << Calendar.new([
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
patco_schedule << Calendar.new([2, 0, 0, 0, 0, 0, 1, 0, patco_schedule_start_date, patco_schedule_end_date])
patco_schedule << Calendar.new([3, 0, 0, 0, 0, 0, 0, 1, patco_schedule_start_date, patco_schedule_end_date])

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

# WIP: timetable processing and Trip/StopTime object assembly

# Will be our final timetable element
timetable = Hash.new()

# Westbound to Philadelphia
timetable[:west] = Array.new(13) { Array.new }

# Eastbound to Lindenwold
timetable[:east] = Array.new(13) { Array.new }

# Starting loop values
timestamp_counter = 0
direction = :west

timetable_items.each do |time|
  # p timestamp_counter
  
  if timestamp_counter == 13 and direction == :west
    direction = :east
    timestamp_counter = 0
  elsif timestamp_counter == 13 and direction == :east
    direction = :west
    timestamp_counter = 0
  end

  unless time[2].nil? # if time item has no data, don't process it
    timetable[direction][timestamp_counter] << time[2]
    timestamp_counter += 1
  else
  end
end

# p timetable[:west][0]

# Assemble CSV rows into a CSV Table object, then output to CSV files
patco_agency_csv = CSV::Table.new(patco_agencies)
File.open("output/agency.txt", "wb") { |file| file.write(patco_agency_csv)  }

patco_calendar_csv = CSV::Table.new(patco_schedule)
File.open("output/calendar.txt", "wb") { |file| file.write(patco_calendar_csv)  }

patco_routes_csv = CSV::Table.new(patco_routes)
File.open("output/routes.txt", "wb") { |file| file.write(patco_routes_csv)  }

patco_stops_csv = CSV::Table.new(patco_stops)
File.open("output/stops.txt", "wb") { |file| file.write(patco_stops_csv)  }

