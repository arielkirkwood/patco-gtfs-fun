class Trip < CSV::Row

  # Function used to instantiate this class.
  def initialize(headers = [:route_id, :service_id, :trip_id], fields)
    # Here, we delegate to the CSV::Row initialize() because we want its goodies included as well.
    super(headers, fields) 
  end
end