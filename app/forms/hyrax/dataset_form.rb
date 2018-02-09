# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetForm < Hyrax::Forms::WorkForm

    self.model_class = ::Dataset

    self.terms += [
      :bibliographic_citation,
      :resource_type,
      :affiliation,
      :alternative,
      :ark,
      :available,
      :doi,
      :format,
      :provenance,
      :rights_note,
      :temporal,
    ]

    self.required_fields = [
      :title,
    ]

    def primary_terms
      required_fields + [ :creator,
                          :publisher,
                          :available,
                          :description,
                          :resource_type,
                          :license,
                          :rights_note,
                          :bibliographic_citation,
                        ]
    end
  end
end
