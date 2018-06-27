module Submissions
  class DocumentDepositAgreement

    FILENAME = 'deposit_agreement.txt'
    TEMP_DIR_PREFIX = 'deposit-agreement-'

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def call
      dir = Dir.mktmpdir(TEMP_DIR_PREFIX)
      file_path = File.join(dir, FILENAME)
      File.open(file_path, 'w') do |f|
        f.write(Nokogiri::HTML(deposit_agreement << "\n\n#{signature}\n").text)
      end
      file_path
    end

    private

    def deposit_agreement
      ContentBlock.for(:agreement).value
    end

    def signature
      "#{user.display_name}\n#{user.netid}\n#{timestamp}"
    end

    def timestamp
      Time.now.strftime('%Y-%m-%d %H:%M')
    end

  end
end
