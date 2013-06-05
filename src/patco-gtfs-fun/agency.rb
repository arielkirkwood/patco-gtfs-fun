class Agency < CSV::Row
  # attr_accessor :headers, :fields (maybe need this in the future?)
  def initialize(headers = ["agency_name", "agency_url", "agency_timezone"], fields)
    super(headers, fields)
  end
end