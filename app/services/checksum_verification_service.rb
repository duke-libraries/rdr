class ChecksumVerificationService

  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    wrapper = event.payload[:wrapper]
    ChecksumVerificationJob.perform_later(wrapper)
  end

  attr_reader :wrapper

  def initialize(wrapper)
    @wrapper = wrapper
  end

  def verify_checksum
    fileset = wrapper.file_set
    if fileset.files.empty?
      raise Rdr::ChecksumInvalid, I18n.t('rdr.fileset_without_files', fs_id: fileset.id)
    else
      if provided_checksum = Importer::Checksum.checksum(wrapper.path)
        verify_provided_checksum(fileset, provided_checksum)
      end
      verify_repository_checksum(fileset)
    end
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
