module Box
  class InitializeSubmissionFolder

    attr_reader :box_client, :deposit_agreement_path, :manifest_path, :user

    def self.call(user, deposit_agreement: nil, manifest: nil)
      new(user, deposit_agreement: deposit_agreement, manifest: manifest).call
    end

    def initialize(user, deposit_agreement: nil, manifest: nil)
      @user = user
      @deposit_agreement_path = deposit_agreement
      @manifest_path = manifest
    end

    def call
      @box_client = Box::Client.new
      submission_folder = create_submission_folder
      add_deposit_agreement(submission_folder) if deposit_agreement_path.present?
      add_manifest_file(submission_folder) if manifest_path.present?
      add_submitter_as_collaborator(submission_folder)
    end

    private

    def create_submission_folder
      folder_prefix = user.netid || user.user_key
      now = Time.now.strftime('%Y%m%d%H%M')
      folder_name = "#{folder_prefix}_#{now}"
      box_client.create_rdr_submission_folder(folder_name)
    end

    def add_deposit_agreement(folder)
      box_client.add_deposit_agreement(folder, deposit_agreement_path)
    end

    def add_manifest_file(folder)
      box_client.add_manifest_file(folder, manifest_path)
    end

    def add_submitter_as_collaborator(folder)
      box_client.add_collaborator(folder, user.user_key)
    end

  end
end
