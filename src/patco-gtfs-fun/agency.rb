class Agency < CSV::Row
  # attr_accessor :headers, :fields (maybe need this in the future?)
  
  # Function used to instantiate this class.
  def initialize(headers = [:agency_name, :agency_url, :agency_timezone], fields)
    # Here, we delegate to the CSV::Row initialize() because we want its goodies included as well.
    super(headers, fields) 
  end
end