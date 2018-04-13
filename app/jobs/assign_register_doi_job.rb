class AssignRegisterDoiJob < ApplicationJob
  queue_as :doi

  def perform(work)
    AssignDoi.call(work)
    work.reload
    CrossrefRegistration.call(work) if work.doi_registerable?
  end

end
