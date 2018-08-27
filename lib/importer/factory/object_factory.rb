require 'importer/log_subscriber'

module Importer
  module Factory
    class ObjectFactory
      extend ActiveModel::Callbacks
      define_model_callbacks :save, :create
      class_attribute :klass
      attr_reader :attributes, :collection_ids, :files_directory, :object, :files, :parent_arks, :visibility

      def initialize(attributes, files_dir = nil)
        @attributes = attributes
        @files_directory = files_dir
        @collection_ids = @attributes.delete(:collection_id)
        @files = @attributes.delete(:file)
        @parent_arks = @attributes.delete(:parent_ark)
        @visibility = @attributes.delete(:visibility)
      end

      def run
        arg_hash = { name: 'CREATE', klass: klass }
        ActiveSupport::Notifications.instrument('import.importer', arg_hash) { create }
        yield(object) if block_given?
        object
      end

      def create
        attrs = create_attributes
        @object = klass.new
        run_callbacks :save do
          run_callbacks :create do
            work_actor.create(environment(attrs))
          end
        end
        log_created(object)
      end

      def create_attributes
        transform_attributes
      end

      def log_created(obj)
        msg = "Created #{klass.model_name.human} #{obj.id}"
        Rails.logger.info(msg)
      end

      def find_by_ark(ark)
        ark_field_name = ActiveFedora.index_field_mapper.solr_name('ark', :stored_sortable)
        results = klass.where(ark_field_name => ark)
        if results.count > 1
          raise Rdr::UnexpectedMultipleResultsError, I18n.t('rdr.unexpected_multiple_results', identifier: ark)
        else
          results.first
        end
      end

      def parent_id(parent_ark)
        if parent = find_by_ark(parent_ark)
          parent.id
        end
      end

      private

      # Override if we need to map the attributes from the parser in
      # a way that is compatible with how the factory needs them.
      def transform_attributes
        based_near_values = attributes.delete(:based_near)
        sanitized_attributes
            .merge(file_attributes)
            .merge(location_attributes(based_near_values))
            .merge(nesting_attributes)
            .merge(visibility_attributes)
            .merge(collection_membership_attributes)
      end

      def sanitized_attributes
        permitted_attributes.each_with_object({}) do |(k, v), memo|
          if klass.delegated_attributes.key?(k)
            value = Array(v)
            memo[k] = klass.multiple?(k) ? value : value.first
          else
            memo[k] = v
          end
        end
      end

      def permitted_attributes
        attributes.slice(*permitted_attribute_names)
      end

      def permitted_attribute_names
        klass.properties.keys.map(&:to_sym) +
            [ :admin_set_id, :parent_ark, :edit_users, :edit_groups, :read_groups, :visibility ]
      end

      def collection_membership_attributes
        collection_ids.present? ? { member_of_collection_ids: collection_ids } : {}
      end

      def file_attributes
        files_directory.present? && files.present? ? { remote_files: remote_files } : {}
      end

      def location_attributes(based_near_values)
        if based_near_values.present?
          { 'based_near_attributes' => based_near_attrs(based_near_values) }
        else
          {}
        end
      end

      def based_near_attrs(based_near_values)
        based_near_values.each_with_object({}).with_index do |(val, hsh), idx|
          hsh[idx.to_s] = { 'id' => val, '_destroy' => '' }
        end
      end

      def nesting_attributes
        parent_arks.present? ? { in_works_ids: parent_arks.map { |ark| parent_id(ark) } } : {}
      end

      def visibility_attributes
        visibility.present? ? { visibility: visibility.first } : {}
      end

      def import_user(attrs)
        attrs[:depositor].present? ? User.find_by_user_key(attrs[:depositor]) : User.batch_user
      end

      def remote_files
        files.map do |file_name|
          f = File.join(files_directory, file_name)
          { url: "file:#{f}", file_name: File.basename(f) }
        end
      end

      # @param [Hash] attrs the attributes to put in the environment
      # @return [Hyrax::Actors::Environment]
      def environment(attrs)
        Hyrax::Actors::Environment.new(@object, Ability.new(import_user(attrs)), attrs)
      end

      def work_actor
        Hyrax::CurationConcern.actor
      end

    end
  end
end
