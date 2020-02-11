# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetPresenter < Hyrax::WorkShowPresenter
    # Account for fields not already delegated to solr_document via
    # https://github.com/samvera/hyrax/blob/master/app/presenters/hyrax/work_show_presenter.rb
    delegate  :affiliation, :alternative, :ark, :available, :based_near,
              :bibliographic_citation, :contact, :doi, :format,
              :funding_agency, :grant_number,
              :in_works_ids, :is_replaced_by, :members, :provenance,
              :related_url, :replaces, :resource_type, :rights_note, :temporal, :top_level, to: :solr_document

    delegate *(Rdr::DatasetVersioning.public_instance_methods), to: :solr_document

    class_attribute :work_presenter_class

    self.work_presenter_class = DatasetPresenter

    def depositor?
      current_ability.current_user.user_key == depositor
    end

    def assignable_doi?
      current_ability.can?(:assign_register_doi, solr_document)
    end

    def file_scan
      @file_scan ||= WorkFilesScanner.call(id, current_ability)
    end

    def file_count
      file_scan.file_count
    end

    def file_size_total
      file_scan.file_size_total
    end

    # Overrides 'Hyrax::WorkShowPresenter#grouped_presenters' to add in the presenters for works in which the current
    # work is nested
    def grouped_presenters(filtered_by: nil, except: nil)
      super.merge(grouped_work_presenters(filtered_by: filtered_by, except: except))
    end

    # modeled on '#grouped_presenters' in Hyrax::WorkShowPresenter, which returns presenters for the collections of
    # which the work is a member
    def grouped_work_presenters(filtered_by: nil, except: nil)
      grouped = in_work_presenters.group_by(&:model_name).transform_keys { |key| key.to_s.underscore }
      grouped.select! { |obj| obj.downcase == filtered_by } unless filtered_by.nil?
      grouped.except!(*except) unless except.nil?
      grouped || {}
    end

    # modeled on '#member_of_collection_presenters' in Hyrax::WorkShowPresenter
    def in_work_presenters
      PresenterFactory.build_for(ids: in_works_ids,
                                 presenter_class: work_presenter_class,
                                 presenter_args: presenter_factory_arguments)
    end

    # Get the presenters for the collections in which the top-level work is a member
    # Collection must be the custom RDR type "Collection" (omit admin sets, user collections, etc.)
    #
    # @return [Array<CollectionPresenter>] presenters
    def toplevel_rdr_collection_presenters
      toplevel_work_collection_presenters.select {|p| p.collection_type.machine_id == 'collection' }
    end

    def ancestor_trail
      docs = ancestor_trail_ids(solr_document).map { |id| ::SolrDocument.find(id) }
      docs.reverse
    end

    private

    # Modeled on '#member_of_collection_presenters' in Hyrax::WorkShowPresenter
    # Get the presenters for all the collections in which the top-level work is a
    # member, no matter what collection type or how deeply nested the current work is.
    # Limit to collections the current user can access.
    #
    # @return [Array<CollectionPresenter>] presenters
    def toplevel_work_collection_presenters
      return [] unless toplevel_work_id.present?
      PresenterFactory.build_for(ids: toplevel_authorized_collections,
                                 presenter_class: collection_presenter_class,
                                 presenter_args: presenter_factory_arguments)
    end

    # Modeled on '#member_of_authorized_parent_collections' in Hyrax::WorkShowPresenter
    def toplevel_authorized_collections
      Hyrax::CollectionMemberService.run(::SolrDocument.find(toplevel_work_id), current_ability).map(&:id)
    end

    def toplevel_work_id
      (id if top_level) || ancestor_trail_ids(solr_document).last || nil
    end

    # Recursively assemble an array of this work's ancestor work ids, provided it
    # has ancestor works, and neither it nor any of its ancestors has multiple parents.
    def ancestor_trail_ids(document, ancestors=[])
      return ancestors if document.in_works_ids.blank?
      return [] if document.in_works_ids.count > 1
      ancestors.concat document.in_works_ids
      ancestor_trail_ids(::SolrDocument.find(document.in_works_ids.first), ancestors)
    end
  end
end
