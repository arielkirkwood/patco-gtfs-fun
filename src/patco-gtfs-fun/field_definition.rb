class FieldDefinition
  attr_accessor :headers

  def initialize(headers = [])
    @headers = headers
  end
end