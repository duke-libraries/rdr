class FileSetDepositorAccessActor < Hyrax::Actors::AbstractActor

  def create(env)
    next_actor.create(env) && grant_depositor_access(env)
  end

  def grant_depositor_access(env)
    file_sets = env.curation_concern.file_sets

    file_sets.each do |fs|
      if ::User.curators.include?(fs.depositor)
        fs.edit_users += [ fs.depositor ]
      else
        fs.read_users += [ fs.depositor ]
      end
      fs.save
    end

  end
end
