class Stop < CSV::Row

  # Function used to instantiate this class.
  def initialize(headers = [:stop_id, :stop_name, :stop_lat, :stop_lon], fields)
    # Here, we delegate to the CSV::Row initialize() because we want its goodies included as well.
    super(headers, fields) 
  end
end