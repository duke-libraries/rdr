class NestedWorkIndexingActor < Hyrax::Actors::AbstractActor

  def create(env)
    nested = env.attributes['in_works_ids'].present?
    next_actor.create(env) && reindex_nested_work(env, nested)
  end

  def update(env)
    # byebug
    work_members = env.attributes.fetch(:work_members_attributes, {})
    # Collect the id's of the works added to or from removed from the parent work and reindex those works as
    # we come back up the actor stack.
    changed_member_ids = changed_memberships(env, work_members)
    next_actor.update(env) && reindex_changed_members(changed_member_ids)
  end

  private

  # Determine works added to or removed from the work being updated.
  def changed_memberships(env, work_members)
    existing_member_ids = env.curation_concern.member_ids
    members_attributes = work_members.values
    changed_member_ids(members_attributes, existing_member_ids)
  end

  # Returns an Array of the id's of works added to or removed from the work being updated.
  def changed_member_ids(members_attributes, existing_member_ids)
    changed = []
    members_attributes.each do |attributes|
      next if attributes['id'].blank?
      if existing_member_ids.include?(attributes['id'])
        changed << attributes['id'] if has_destroy_flag?(attributes)
      else
        changed << attributes['id']
      end
    end
    changed
  end

  def reindex_nested_work(env, nested)
    return true unless nested
    reindex_works(Array(env.curation_concern.id))
    true
  end

  def reindex_changed_members(changed_member_ids)
    return true unless changed_member_ids.present?
    reindex_works(changed_member_ids)
    true
  end

  def reindex_works(work_ids)
    work_ids.each do |id|
      ActiveFedora::Base.find(id).update_index
    end
  end

  # Copied from Hyrax::Actors::AttachMembersActor#has_destroy_flag?
  # Determines if a hash contains a truthy _destroy key.
  # rubocop:disable Naming/PredicateName
  def has_destroy_flag?(hash)
    ActiveFedora::Type::Boolean.new.cast(hash['_destroy'])
  end
  # rubocop:enable Naming/PredicateName

end
