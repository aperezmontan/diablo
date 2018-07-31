class GameAdderError < StandardError
  attr_reader :input

  def initialize(input:, message: nil)
    @input = input
    @message = message || default_message

    super(@message)
  end

  private

  def default_message
    klass = input.nil? ? 'nil' : input.class
    "Expecting Pool, received #{klass}"
  end
end