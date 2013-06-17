# Trip class
# https://developers.google.com/transit/gtfs/reference#trips_fields
class Trip < CSV::Row

  # Function used to instantiate this class.
  def initialize(headers = [:route_id, :service_id, :trip_id, :trip_headsign, :direction_id], fields)
    # Here, we delegate to the CSV::Row initialize() because we want its goodies included as well.
    super(headers, fields) 
  end
end