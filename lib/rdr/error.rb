module Rdr

  # Base class for custom exceptions
  class Error < StandardError; end

  class ChecksumInvalid < Error; end

  # More than one found when no more than one expected
  class UnexpectedMultipleResultsError < Error; end

  # Unexpected dataset version result
  class DatasetVersionError < Error; end

  class DoiAssignmentError < Error; end

  # Error response from Crossref
  class CrossrefRegistrationError < Error; end

end
