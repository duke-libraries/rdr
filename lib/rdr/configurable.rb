module Rdr
  module Configurable
    extend ActiveSupport::Concern

    included do

      # reason recorded in Ezid when an ARK is made unavailable due to object deaccession
      mattr_accessor :deaccession_reason do
        ENV["DEACCESSION_REASON"] || 'Deaccessioned from repository'
      end

      # default from address for emails sent by application
      mattr_accessor :default_from_address do
        ENV["DEFAULT_FROM_ADDRESS"] || 'from@example.com'
      end

      # URL of depositor modification request form
      mattr_accessor :depositor_request_form do
        ENV["DEPOSITOR_REQUEST_FORM"]
      end

      # Email verification token lifespan as an ActiveSupport::Duration
      # Currently used only in relation to Export Files functionality
      mattr_accessor :email_verification_token_lifespan do
        if value = ENV["EMAIL_VERIFICATION_TOKEN_LIFESPAN"]
          eval(value)
        else
          48.hours
        end
      end

      # Base URL for export files - include trailing slash
      mattr_accessor :export_files_base_url do
        ENV["EXPORT_FILES_BASE_URL"] || "/export_files/"
      end

      # Contact email for export files
      mattr_accessor :export_files_contact_email do
        ENV["EXPORT_FILES_CONTACT_EMAIL"] || 'from@example.com'
      end

      mattr_accessor :export_files_max_payload_size do
        if value = ENV["EXPORT_FILES_MAX_PAYLOAD_SIZE"]
          value.to_i
        else
          100 * 10**9 # 100Gb
        end
      end

      # Directory to store export files
      mattr_accessor :export_files_store do
        ENV["EXPORT_FILES_STORE"] || File.join(Rails.root, "public", "export_files")
      end

      # Source-Organization for export files bag info
      mattr_accessor :export_files_source_organization do
        ENV["EXPORT_FILES_SOURCE_ORGANIZATION"] || 'Duke University Libraries'
      end

      # Host name for use in non-web-request situations
      mattr_accessor :host_name do
        ENV["HOST_NAME"]
      end

      # Crossref login_id
      mattr_accessor :crossref_user do
        ENV["CROSSREF_USER"] || "NOT_SET"
      end

      # Crossref login_password
      mattr_accessor :crossref_password do
        ENV["CROSSREF_PASSWORD"] || "NOT_SET"
      end

      # Crossref registration host
      mattr_accessor :crossref_host do
        ENV["CROSSREF_HOST"] || "test.crossref.org"
      end

      # Geonames user account
      mattr_accessor :geonames_user do
        ENV["GEONAMES_USER"] || "NOT_SET"
      end

      # The number of words (space-delimited) at which to collapse the display of
      # a long metadata value; click a Read More link to expand.
      # E.g., Description field on a work show page.
      mattr_accessor :expandable_text_word_cutoff do
        ENV.fetch("EXPANDABLE_TEXT_WORD_CUTOFF", 105).to_i
      end

      # The base Box folder for RDR Submissions
      mattr_accessor :box_base_folder_rdr_submissions do
        ENV["BOX_BASE_FOLDER_RDR_SUBMISSIONS"] || "NOT_SET"
      end

      # The base URL for accessing the Box instance used for RDR Submissions
      mattr_accessor :box_base_url_rdr_submissions do
        ENV["BOX_BASE_URL_RDR_SUBMISSIONS"] || "NOT_SET"
      end

      # The email address for the curation group
      mattr_accessor :curation_group_email do
        ENV["CURATION_GROUP_EMAIL"] || 'curators@example.org'
      end

      # Value used in Importer manifest to separate multiple values in a single
      # CSV cell.
      mattr_accessor :csv_mv_separator do
        ENV["CSV_MV_SEPARATOR"] || "|"
      end

    end

    module ClassMethods
      def configure
        yield self
      end
    end

  end
end
