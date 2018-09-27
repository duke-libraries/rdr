module Importer
  # Import a csv file with one work per row. The first row of the csv should be a
  # header row.
  class CSVImporter

    attr_reader :checksum_file, :depositor, :files_directory, :manifest_file, :model, :on_behalf_of

    # @param [String] manifest_file path to CSV file
    # @param [String] files_directory path, passed to factory constructor
    # @param [Hash] opts options for performing the import
    # @option opts [String] :checksum_file path to checksum file
    # @option opts [String] :depositor user_key of the User performing the deposit
    # @option opts [String, Class] :model the stringable first (Xxx) portion of the "XxxFactory" constant to be used
    #   for each row
    def initialize(manifest_file, files_directory, opts={})
      @manifest_file = manifest_file
      @files_directory = files_directory
      @checksum_file = opts.fetch(:checksum_file, nil)
      @depositor = opts.fetch(:depositor, nil)
      @model = opts.fetch(:model, 'Dataset')
    end

    # @return [Integer] count of objects created
    def import_all
      load_checksums if checksum_file
      count = 0
      parser.each do |attributes|
        attrs = attributes.merge(deposit_attributes)
        import_batch_object(attrs)
        count += 1
      end
      count
    end

    def import_batch_object(attributes)
      ark = attributes[:ark]&.first
      if ark.present? && parser.parent_arks.include?(ark)
        BatchObjectImportJob.perform_now(model, attributes, files_directory)
      else
        BatchObjectImportJob.perform_later(model, attributes, files_directory)
      end
    end

    private

    def deposit_attributes
      { depositor: depositor }
    end

    def parser
      CSVParser.new(manifest_file)
    end

    def load_checksums
      Checksum.import_data(checksum_file)
    end

  end
end
