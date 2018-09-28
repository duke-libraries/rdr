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

    def assign_register_doi
      dataset = Dataset.find(params['id'])
      authorize! :assign_register_doi, dataset
      if dataset.doi_assignable?
        AssignRegisterDoiJob.perform_later(dataset)
        flash[:notice] = I18n.t('rdr.doi.assigment_registration_job_enqueued')
      else
        flash[:alert] = I18n.t('rdr.doi.not_assignable')
      end
      redirect_to([main_app, dataset])
    end

    private

    def check_dataset_version
      doc = ::SolrDocument.find(params[:id])
      unless doc.latest_dataset_version?
        if params[:dataset_version] == 'latest'
          redirect_to [main_app, doc.latest_dataset_version]
        else
          flash.now[:error] = t('.previous_version') % latest_dataset_version_link.html_safe
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
