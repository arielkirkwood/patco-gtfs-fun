# Calendar class
# https://developers.google.com/transit/gtfs/reference#calendar_fields
class Calendar < CSV::Row

  # Function used to instantiate this class.
  def initialize(headers = [:service_id, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :start_date, :end_date], fields)
    # Here, we delegate to the CSV::Row initialize() because we want its goodies included as well.
    super(headers, fields) 
  end
end