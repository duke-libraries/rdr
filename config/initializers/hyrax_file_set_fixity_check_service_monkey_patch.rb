Hyrax::FileSetFixityCheckService.class_eval do

  private

  # Retrieve or generate the fixity check for a file
  # (all versions are checked for versioned files unless latest_version_only set)
  # @param [ActiveFedora::File] file to fixity check
  # @param [Array] log container for messages
  def fixity_check_file(file)
    versions = file.has_versions? ? file.versions.all : [file]

    # Patch the following line so that '#max_by(&:created)' is only called on the 'versions' array if its
    # elements respond to :created; i.e., only if array contains ActiveFedora::VersionsGraph::ResourceVersion
    # object(s) (and not Hydra::PCDM::File object(s))
    # versions = [versions.max_by(&:created)] if latest_version_only
    versions = [versions.max_by(&:created)] if file.has_versions? && latest_version_only

    versions.collect { |v| fixity_check_file_version(file.id, v.uri.to_s) }.flatten
  end

end
