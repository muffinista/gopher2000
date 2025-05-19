# frozen_string_literal: true

module Gopher
  # base error class
  class GopherError < StandardError; end

  # When a selector isn't found in the route map
  class NotFoundError < GopherError; end

  # Invalid gopher requests
  class InvalidRequest < GopherError; end

  # Template not found in local or global space
  class TemplateNotFound < GopherError; end
end
