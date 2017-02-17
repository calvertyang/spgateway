# frozen_string_literal: true
module Spgateway
  # Generic Spgateway exception class.
  class SpgatewayError < StandardError; end
  class MissingOption < SpgatewayError; end
  class MissingParameter < SpgatewayError; end
  class InvalidMode < SpgatewayError; end
  class UnsupportedType < SpgatewayError; end
end
