class MintPublishArkJob < ApplicationJob
  queue_as :ark

  def perform(work)
    MintPublishArk.call(work)
  end

end
