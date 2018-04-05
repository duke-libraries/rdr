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
          redirect_to [main_app, doc.latest_dataset_version]
        else
          flash.now[:notice] = t('.previous_version') % latest_dataset_version_link.html_safe
        end
      end
    end

    def latest_dataset_version_link
      uri = URI.parse(request.original_url)
      uri.query = "dataset_version=latest"
      helpers.link_to(uri.to_s, uri.to_s)
    end

  end
end
