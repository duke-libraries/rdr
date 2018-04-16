module Importer
  class CSVManifest
    include ActiveModel::Validations

    attr_reader :files_directory, :manifest_file

    validate :files_must_exist

    def initialize(manifest_file, files_directory)
      @manifest_file = manifest_file
      @files_directory = files_directory
    end

    def parser
      CSVParser.new(manifest_file)
    end

    def files_must_exist
      parser.each do |attributes|
        validate_files attributes[:file] if attributes[:file]
      end
    end

    def validate_files(files)
      files.each do |file|
        validate_file(file)
      end
    end

    def validate_file(file)
      unless File.exist?(File.join(files_directory, file))
        errors.add(:files, "File not found: #{File.join(files_directory, file)}")
      end
    end

  end
end
