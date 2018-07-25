module Submissions
  class CreateManifest

    attr_reader :submission, :hdr_arr, :data_arr, :manifest_path

    SUBMISSION_MULTIPLES = [ :creator, :contributor, :affiliation, :subject,
                             :based_near, :temporal, :language, :format, :related_url ]

    MANIFEST_ATTRS = Submission::SUBMISSION_ATTRIBUTES - [:doi_exists, :using_cc0]

    CC0_LICENSE = "https://creativecommons.org/publicdomain/zero/1.0/"

    FILENAME = 'manifest.csv'
    TEMP_DIR_PREFIX = 'manifest-'

    def self.call(submission)
      new(submission).call
    end

    def initialize(submission)
      @submission = submission
      @data_arr = []
      @hdr_arr = []
    end

    def call
      dir = Dir.mktmpdir(TEMP_DIR_PREFIX)
      @manifest_path = File.join(dir, FILENAME)
      write_manifest
      manifest_path
    end

    private

    def multiple?(submission_field)
      SUBMISSION_MULTIPLES.include? submission_field
    end

    def write_manifest
      MANIFEST_ATTRS.each do |attr|
        if submission.send(attr).present?
          value = submission.send(attr).strip
          write_fields_for_csv(attr, value)
        end
      end
      process_cc0_license unless submission.license.present?
      write_csv_file(hdr_arr, data_arr)
    end

    def process_cc0_license
      attr = :license
      value = CC0_LICENSE
      write_fields_for_csv(attr, value)
    end

    def write_fields_for_csv(attr, value)
      if multiple?(attr)
        value.split(';').each do |el|
          hdr_arr << attr
          data_arr << el.strip
        end
      else
        hdr_arr << attr
        data_arr << value
      end
    end

    def write_csv_file(hdr_arr, data_arr)
      CSV.open(manifest_path, "w") do |csv|
        csv << hdr_arr
        csv << data_arr
      end
    end
  end
end
