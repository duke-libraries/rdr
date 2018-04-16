module Importer
  module Factory
    class DatasetFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Dataset

    end
  end
end
