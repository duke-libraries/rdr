module Submissions
  class CreateDepositInstructions

    FILENAME = 'FILE_UPLOAD_INSTRUCTIONS.txt'
    TEMP_DIR_PREFIX = 'deposit-instructions-'

    def self.call
      new.call
    end

    def call
      dir = Dir.mktmpdir(TEMP_DIR_PREFIX)
      file_path = File.join(dir, FILENAME)
      File.open(file_path, 'w') do |f|
        f.write(I18n.t("rdr.submissions.instructions_text", email: Rdr.curation_group_email))
      end
      file_path
    end

  end
end
