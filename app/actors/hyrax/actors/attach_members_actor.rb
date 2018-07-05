module Hyrax
  module Actors
    # Override Hyrax::Actors::AttachMembersActor to add functionality to re-index works that are added to or removed
    # from other works.  This is needed because we index whether a work is a "top level" (non-nested) work.  Adding a
    # work to or removing it from membership in another work will often change whether it is a "top level" work or not
    # and we need to insure that the added / removed works are reindexed to reflect this.
    # The added code duplicates some existing code but that allows the existing code to remain more or less intact
    # without significant refactoring.
    #
    # Attach or remove child works to/from this work. This decodes parameters
    # that follow the rails nested parameters conventions:
    # e.g.
    #   'work_members_attributes' => {
    #     '0' => { 'id' = '12312412'},
    #     '1' => { 'id' = '99981228', '_destroy' => 'true' }
    #   }
    #
    # The goal of this actor is to mutate the ordered_members with as few writes
    # as possible, because changing ordered_members is slow. This class only
    # writes changes, not the full ordered list.
    class AttachMembersActor < Hyrax::Actors::AbstractActor
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        attributes_collection = env.attributes.delete(:work_members_attributes)
        # Collect the id's of the works added to or from removed from the parent work and reindex those works as
        # we come back up the actor stack.
        changed_member_ids = changed_memberships(env, attributes_collection)
        assign_nested_attributes_for_collection(env, attributes_collection) &&
            next_actor.update(env) && reindex_changed_members(changed_member_ids)
      end

      private

      # Attaches any unattached members.  Deletes those that are marked _delete
      # @param [Hash<Hash>] a collection of members
      def assign_nested_attributes_for_collection(env, attributes_collection)
        return true unless attributes_collection
        attributes_collection = attributes_collection.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes }
        # checking for existing works to avoid rewriting/loading works that are
        # already attached
        existing_works = env.curation_concern.member_ids
        attributes_collection.each do |attributes|
          next if attributes['id'].blank?
          if existing_works.include?(attributes['id'])
            remove(env.curation_concern, attributes['id']) if has_destroy_flag?(attributes)
          else
            add(env, attributes['id'])
          end
        end
      end

      # Adds the item to the ordered members so that it displays in the items
      # along side the FileSets on the show page
      def add(env, id)
        member = ActiveFedora::Base.find(id)
        return unless env.current_ability.can?(:edit, member)
        env.curation_concern.ordered_members << member
      end

      # Remove the object from the members set and the ordered members list
      def remove(curation_concern, id)
        member = ActiveFedora::Base.find(id)
        curation_concern.ordered_members.delete(member)
        curation_concern.members.delete(member)
      end

      # Determines if a hash contains a truthy _destroy key.
      # rubocop:disable Naming/PredicateName
      def has_destroy_flag?(hash)
        ActiveFedora::Type::Boolean.new.cast(hash['_destroy'])
      end
      # rubocop:enable Naming/PredicateName

      # Reindex works based on a list of id's.
      # Used to reindex works added to or removed from another work.
      def reindex_changed_members(member_ids)
        member_ids.each do |id|
          member = ActiveFedora::Base.find(id)
          member.update_index
        end
      end

      # Determine works added to or removed from the work being updated.
      def changed_memberships(env, attributes_collection)
        existing_member_ids = env.curation_concern.member_ids
        members_attributes = attributes_collection.values
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

    end
  end
end
