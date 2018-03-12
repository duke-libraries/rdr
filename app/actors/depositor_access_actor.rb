class DepositorAccessActor < Hyrax::Actors::AbstractActor
  def create(env)
    next_actor.create(env) && grant_depositor_access(env)
  end

  def grant_depositor_access(env)
    work = env.curation_concern
    depositor = work.depositor

    unless ::User.curators.include?(depositor)
      work.read_users += [depositor]
      work.edit_users -= [depositor]
      work.save!
      # If there are a lot of members, granting access to each could take a
      # long time. Do this work in the background.
      Hyrax::GrantReadToMembersJob.perform_later(work, depositor)
      Hyrax::RevokeEditFromMembersJob.perform_later(work, depositor)
    end
  end
end