# Stop time class
# https://developers.google.com/transit/gtfs/reference#stop_times_fields
class StopTime < CSV::Row

  # Function used to instantiate this class.
  def initialize(headers = [:trip_id, :arrival_time, :departure_time, :stop_id, :stop_sequence], fields)
    # Here, we delegate to the CSV::Row initialize() because we want its goodies included as well.
    super(headers, fields) 
  end
end