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
    # @option opts [String] :on_behalf_of user_key of the User on whose behalf the deposit is being made
    #   (if proxy deposit)
    def initialize(manifest_file, files_directory, opts={})
      @manifest_file = manifest_file
      @files_directory = files_directory
      @checksum_file = opts.fetch(:checksum_file, nil)
      @depositor = opts.fetch(:depositor, nil)
      @model = opts.fetch(:model, 'Dataset')
      @on_behalf_of = opts.fetch(:on_behalf_of, nil)
    end

    # @return [Integer] count of objects created
    def import_all
      load_checksums if checksum_file
      count = 0
      parser.each do |attributes|
        attrs = attributes.merge(deposit_attributes)
        create_fedora_objects(attrs)
        count += 1
      end
      count
    end

    private

    def deposit_attributes
      { depositor: depositor, on_behalf_of: on_behalf_of }
    end

    def parser
      CSVParser.new(manifest_file)
    end

    # @return [Class] the factory class to be used
    def factory_class(model)
      Factory.for(model.to_s)
    end

    # Build a factory to create the objects in fedora.
    # @param [Hash<Symbol => String>] attributes
    def create_fedora_objects(attributes)
      fc = factory_class(model)
      f = fc.new(attributes, files_directory)
      f.run
    end

    def load_checksums
      Checksum.import_data(checksum_file)
    end

  end
end
