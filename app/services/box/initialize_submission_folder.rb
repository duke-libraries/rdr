module Box
  class InitializeSubmissionFolder

    attr_reader :box_client, :manifest_path, :user_key

    def self.call(user_key, manifest_path)
      new(user_key, manifest_path).call
    end

    def initialize(user_key, manifest_path)
      @user_key = user_key
      @manifest_path = manifest_path
    end

    def call
      @box_client = Box::Client.new
      submission_folder = create_submission_folder
      add_manifest_file(submission_folder)
      add_submitter_as_collaborator(submission_folder)
    end

    private

    def create_submission_folder
      netid = extract_netid
      now = Time.now.strftime('%Y%m%d%H%M')
      folder_name = "#{netid}_#{now}"
      box_client.create_rdr_submission_folder(folder_name)
    end

    def add_manifest_file(folder)
      box_client.add_manifest_file(folder, manifest_path)
    end

    def add_submitter_as_collaborator(folder)
      box_client.add_collaborator(folder, user_key)
    end

    def extract_netid
      user_key.split('@').first
    end

  end
end
