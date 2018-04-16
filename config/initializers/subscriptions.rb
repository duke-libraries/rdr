ActiveSupport::Notifications.subscribe(Rdr::Notifications::FILE_INGEST_FINISHED, ChecksumVerificationService)
