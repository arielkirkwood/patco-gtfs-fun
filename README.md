# patco-gtfs-fun
This project was created for my [INFO 480](http://seangoggins.net/info480) course.

Its goal is to put together valid [GTFS](http://en.wikipedia.org/wiki/General_Transit_Feed_Specification) files using publicly available data for the [PATCO High-speed Line](http://en.wikipedia.org/wiki/PATCO_Speedline).

# Output Files

## Required
### [agency.txt](https://developers.google.com/transit/gtfs/reference#agency_fields)  
One or more transit agencies that provide the data in this feed.
### [stops.txt](https://developers.google.com/transit/gtfs/reference#stops_fields)  
Individual locations where vehicles pick up or drop off passengers.
### [routes.txt](https://developers.google.com/transit/gtfs/reference#routes_fields)  
Transit routes. A route is a group of trips that are displayed to riders as a single service.
### [trips.txt](https://developers.google.com/transit/gtfs/reference#trips_fields)  
Trips for each route. A trip is a sequence of two or more stops that occurs at specific time.
### [stop_times.txt](https://developers.google.com/transit/gtfs/reference#stop_times_fields)  
Times that a vehicle arrives at and departs from individual stops for each trip.
### [calendar.txt](https://developers.google.com/transit/gtfs/reference#calendar_fields)  
Dates for service IDs using a weekly schedule. Specify when service starts and ends, as well as days of the week where service is available.

## Optional (outside the scope of this project)
### [calendar_dates.txt](https://developers.google.com/transit/gtfs/reference#calendar_dates_fields)
Exceptions for the service IDs defined in the calendar.txt file. If calendar_dates.txt includes ALL dates of service, this file may be specified instead of calendar.txt.
### [fare_attributes.txt](https://developers.google.com/transit/gtfs/reference#fare_attributes_fields)
Fare information for a transit organization's routes.
### [fare_rules.txt](https://developers.google.com/transit/gtfs/reference#fare_rules_fields)
Rules for applying fare information for a transit organization's routes.
### [shapes.txt](https://developers.google.com/transit/gtfs/reference#shapes_fields)
Rules for drawing lines on a map to represent a transit organization's routes.
### [frequencies.txt](https://developers.google.com/transit/gtfs/reference#frequencies_fields)
Headway (time between trips) for routes with variable frequency of service.
### [transfers.txt](https://developers.google.com/transit/gtfs/reference#transfers_fields)
Rules for making connections at transfer points between routes.
### [feed_info.txt](https://developers.google.com/transit/gtfs/reference#feed_info_fields)
Additional information about the feed itself, including publisher, version, and expiration information.

## Sources
* [GTFS Reference - Google Developers](https://developers.google.com/transit/gtfs/reference)
