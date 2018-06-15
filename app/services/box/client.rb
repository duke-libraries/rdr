require 'boxr'

module Box
  class Client

    attr_reader :boxr_client

    def self.refresh_tokens
      new_tokens = Boxr::refresh_tokens(Box::RefreshToken.last.token)
      if new_tokens.present?
        Box::AccessToken.create(token: new_tokens.access_token) if new_tokens.access_token.present?
        Box::RefreshToken.create(token: new_tokens.refresh_token) if new_tokens.refresh_token.present?
      end
    rescue Boxr::BoxrError => e
      handle_boxr_error(e, 'refreshing Box auth tokens')
    end

    def initialize
      token_refresh_callback = lambda { |access, refresh, identifier| self.class.refresh_tokens }
      @boxr_client = Boxr::Client.new(Box::AccessToken.last.token,
                                      refresh_token: Box::RefreshToken.last.token,
                                      &token_refresh_callback)
    end

    def method_missing(name, *args, &block)
      if boxr_client.respond_to?(name)
        boxr_client.send(name, *args, &block)
      else
        super
      end
    end

    def rdr_submissions_base_folder
      self.folder_from_path(Rdr.box_base_folder_rdr_submissions)
    rescue Boxr::BoxrError => e
      self.class.handle_boxr_error(e, "retrieving RDR submissions base folder #{Rdr.box_base_folder_rdr_submissions}")
    end

    def create_rdr_submission_folder(folder_name)
      self.create_folder(folder_name, rdr_submissions_base_folder)
    rescue Boxr::BoxrError => e
      self.class.handle_boxr_error(e, "creating RDR submission folder #{folder_name}")
    end

    def add_manifest_file(folder, manifest_path)
      self.upload_file(manifest_path, folder)
    rescue Boxr::BoxrError => e
      self.class.handle_boxr_error(e, "adding manifest file #{manifest_path} to #{folder.name}")
    end

    def add_collaborator(folder, login, role='editor')
      self.add_collaboration(folder, { login: login }, role)
    rescue Boxr::BoxrError => e
      self.class.handle_boxr_error(e, "adding collaborator #{login} to #{folder.name} as #{role}")
    end

    private

    def self.handle_boxr_error(e, action)
      Rails.logger.error "Error #{action}: #{e}"
      raise Rdr::BoxError.new("Error #{action}: #{e}")
    end

  end
end
