class Route < CSV::Row

  # Function used to instantiate this class.
  def initialize(headers = [:route_id, :route_short_name, :route_long_name, :route_type], fields)
    # Here, we delegate to the CSV::Row initialize() because we want its goodies included as well.
    super(headers, fields) 
  end
end