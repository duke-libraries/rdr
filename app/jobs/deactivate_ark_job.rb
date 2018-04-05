class DeactivateArkJob < ApplicationJob
  queue_as :ark

  def perform(ark)
    DeactivateArk.call(ark)
  end

end
