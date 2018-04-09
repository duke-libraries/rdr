class AssignRegisterDoiJob < ApplicationJob
  queue_as :doi

  def perform(work)
    # Placeholder -- to be implemented in RDR-195.
  end

end
