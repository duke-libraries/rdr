class ExportFilesController < ApplicationController

  rescue_from ActionController::ParameterMissing do |e|
    flash.now[:error] = e.message
    render :new
  end

  def new
    repo_id = params.require(:id)
    title = SolrDocument.find(repo_id).title.first
    @basename = ExportFiles::Package.normalize_work_title(title, ExportFiles::Package::BASENAME_MAX_LENGTH)
  end

  def create
    @repo_id = params.require(:id)
    basename = params.require(:basename)
    @export = ExportFiles::Package.new(@repo_id,
                                       ability: current_ability,
                                       basename: basename)
    if @export.valid?
      @confirmed = params[:confirmed]
      if @confirmed
        ExportFilesJob.perform_later(@repo_id,
                                     current_user.id,
                                     nil,
                                     @export.basename)
      else
        @export.scan
      end
    else # not valid
      flash.now[:error] = "Export request cannot be processed: " +
          @export.errors.full_messages.join("; ")
      render :new
    end
  end

end
