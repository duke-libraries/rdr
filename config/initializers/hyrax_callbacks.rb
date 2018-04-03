# Override initialization of :after_create_concern callback to add MintPublishArkJob.perform_later
Hyrax.config.callback.set(:after_create_concern) do |curation_concern, user|
  ContentDepositEventJob.perform_later(curation_concern, user)
  MintPublishArkJob.perform_later(curation_concern)
end
