# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetForm < Hyrax::Forms::WorkForm

    self.model_class = ::Dataset

    self.terms += [
      :resource_type,
      :affiliation,
      :alternative,
      :ark,
      :available,
      :doi,
      :format,
      :provenance,
      :temporal,
    ]

    self.required_fields = [
      :title,
      :creator,
      :publisher,
      :available,
      :description,
      :resource_type,
      :license,
      :bibliographic_citation,
    ]

  end
end
