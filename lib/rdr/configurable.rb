module Rdr
  module Configurable
    extend ActiveSupport::Concern

    included do

      # URL of depositor modification request form
      mattr_accessor :depositor_request_form do
        ENV["DEPOSITOR_REQUEST_FORM"]
      end

      # Base URL for export files - include trailing slash
      mattr_accessor :export_files_base_url do
        ENV["EXPORT_FILES_BASE_URL"] || "/export_files/"
      end

      # Contact email for export files
      mattr_accessor :export_files_contact_email do
        ENV["EXPORT_FILES_CONTACT_EMAIL"] || 'ddrhelp@duke.edu'
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

      # ID of AdminSet to use unless otherwise specified
      mattr_accessor :preferred_admin_set_id

    end

    module ClassMethods
      def configure
        yield self
      end
    end

  end
end
