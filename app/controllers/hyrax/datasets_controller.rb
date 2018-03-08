# Generated via
#  `rails generate hyrax:work Dataset`

module Hyrax
  class DatasetsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Dataset

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DatasetPresenter

    before_action :check_dataset_version, only: :show

    private

    def check_dataset_version
      doc = ::SolrDocument.find(params[:id])
      unless doc.latest_dataset_version?
        if params[:dataset_version] == 'latest'
          redirect_to hyrax_dataset_path(doc.latest_dataset_version)
        else
          flash.now[:info] = t('.previous_version') %
                             "#{hyrax_dataset_path(doc)}?dataset_version=latest"
        end
      end
    end

  end
end
