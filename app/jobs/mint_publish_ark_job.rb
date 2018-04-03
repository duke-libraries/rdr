class MintPublishArkJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(work)
    MintPublishArk.call(work)
  end

end
