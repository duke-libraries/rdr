module Rdr

  # Base class for custom exceptions
  class Error < StandardError; end

  # More than one found when no more than one expected
  class UnexpectedMultipleResultsError < Error; end

end
