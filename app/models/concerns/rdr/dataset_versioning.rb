module Rdr
  module DatasetVersioning

    def has_multiple_dataset_versions?
      has_next_dataset_version? || has_previous_dataset_version?
    end

    def is_latest_dataset_version?
      !has_next_dataset_version?
    end

    alias_method :latest_dataset_version?, :is_latest_dataset_version?

    def latest_dataset_version
      latest_dataset_version? ? self : dataset_versions.latest_version
    end

    def has_previous_dataset_version?
      replaces.present?
    end

    def has_next_dataset_version?
      is_replaced_by.present?
    end

    def previous_dataset_version_query
      raise NotImplementedError,
            "Modules including Rdr::DatasetVersioning must implement the previous_dataset_version_query instance method."
    end

    def next_dataset_version_query
      raise NotImplementedError,
            "Modules including Rdr::DatasetVersioning must implement the next_dataset_version_query instance method."
    end

    def previous_dataset_version
      if has_previous_dataset_version?
        results = previous_dataset_version_query
        if results.empty?
          raise DatasetVersionError, "Unable to find previous version of Dataset #{id}."
        end
        results.first
      end
    end

    def next_dataset_version
      if has_next_dataset_version?
        results = next_dataset_version_query
        if results.empty?
          raise DatasetVersionError, "Unable to find next version of Dataset #{id}."
        end
        results.first
      end
    end

    def dataset_versions
      @dataset_versions ||= DatasetVersions.new(self)
    end

  end
end
