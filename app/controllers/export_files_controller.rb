class ExportFilesController < ApplicationController

  rescue_from ActionController::ParameterMissing do |e|
    flash.now[:error] = e.message
    render :new
  end

  def new
    repo_id = new_params.require(:id)
    @email = new_params[:email]
    if current_user || @email.present?
      title = SolrDocument.find(repo_id).title.first
      @basename = ExportFiles::Package.normalize_work_title(title, ExportFiles::Package::BASENAME_MAX_LENGTH)
    else
      render 'export_files/unauthenticated'
    end
  end

  def create
    @repo_id = create_params.require(:id)
    basename = create_params.require(:basename)
    @email = create_params[:email]
    @export = ExportFiles::Package.new(@repo_id,
                                       ability: current_ability,
                                       basename: basename)
    if @export.valid?
      @confirmed = create_params[:confirmed]
      if @confirmed
        user_id = current_user ? current_user.id : nil
        ExportFilesJob.perform_later(@repo_id,
                                     user_id,
                                     @email,
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

  private

  def new_params
    params.permit(:email, :id)
  end

  def create_params
    params.permit(:basename, :confirmed, :email, :id)
  end
end
