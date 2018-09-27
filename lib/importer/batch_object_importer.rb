module Importer
  class BatchObjectImporter

    attr_reader :attributes, :files_directory, :model

    def self.call(model, attributes, files_directory = nil)
      new(model, attributes, files_directory).call
    end

    def initialize(model, attributes, files_directory = nil)
      @model = model
      @attributes = attributes
      @files_directory = files_directory
    end

    def call
      fc = factory_class(model)
      f = fc.new(attributes, files_directory)
      f.run
    end

    def factory_class(model)
      Factory.for(model.to_s)
    end

  end
end
