class IngestJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  after_perform do |job|
    # We want the lastmost Hash, if any.
    opts = job.arguments.reverse.detect { |x| x.is_a? Hash } || {}
    wrapper = job.arguments.first
    ContentNewVersionEventJob.perform_later(wrapper.file_set, wrapper.user) if opts[:notification]
  end

  # @param [JobIoWrapper] wrapper
  # @param [Boolean] notification send the user a notification, used in after_perform callback
  # @see 'config/initializers/hyrax_callbacks.rb'
  # rubocop:disable Lint/UnusedMethodArgument
  def perform(wrapper, notification: false)
    wrapper.ingest_file
    verify_checksum(wrapper)
  end

  def verify_checksum(wrapper)
    fileset = wrapper.file_set
    if provided_checksum = Importer::Checksum.checksum(wrapper.path)
      verify_provided_checksum(fileset, provided_checksum)
    end
    verify_repository_checksum(fileset)
  end

  # Verifies the checksum stored in the repository against a provided checksum.
  def verify_provided_checksum(fileset, provided_checksum)
    repo_checksum = fileset.original_file.checksum.value
    unless repo_checksum == provided_checksum
      raise Rdr::ChecksumInvalid,
            I18n.t('rdr.provided_checksum_mismatch', fs_id: fileset.id, provided_cksum: provided_checksum,
                   repo_cksum: repo_checksum)
    end
  end

  # Asks the FileSetFixityCheckService to perform a fixity check.
  # In the current implementation, this triggers a fixity check operation in Fedora (i.e., compares the checksum
  # stored in Fedora with the checksum of the file stored in Fedora).
  def verify_repository_checksum(fileset)
    fc_svc = Hyrax::FileSetFixityCheckService.new(fileset, async_jobs: false, latest_version_only: true)
    fixity_check_response = fc_svc.fixity_check
    unless fixity_check_response.values.first.first.passed
      raise Rdr::ChecksumInvalid,
            I18n.t('rdr.repository_checksum_failure', fs_id: fileset.id)
    end
  end

end
