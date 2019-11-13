class ExportFilesController < ApplicationController

  rescue_from ActionController::ParameterMissing do |e|
    flash.now[:error] = e.message
    render :new
  end

  def new
    repo_id = new_params.require(:id)
    @login = new_params[:login]
    token = ActionController::Base.helpers.sanitize(new_params[:token])
    if token.present?
      begin
        @email = validate_token(token)
      rescue Rdr::InvalidEmailVerificationToken => e
        Rails.logger.error(e.message)
        flash[:error] = I18n.t('rdr.batch_export.email_verification.invalid_token_user_message')
        redirect_to(hyrax_dataset_path(repo_id)) and return
      end
    end
    if current_user || @email.present?
      title = SolrDocument.find(repo_id).title.first
      @basename = ExportFiles::Package.normalize_work_title(title, ExportFiles::Package::BASENAME_MAX_LENGTH)
    elsif @login.present?
      store_location_for(:user, export_files_path)
      authenticate_user!
    else
      render 'export_files/unauthenticated'
    end
  end

  def create
    repo_id = create_params.require(:id)
    basename = create_params.require(:basename)
    @email = create_params[:email]
    @export = ExportFiles::Package.new(repo_id,
                                       ability: current_ability,
                                       basename: basename)
    if @export.valid?
      @confirmed = create_params[:confirmed]
      if @confirmed
        user_id = current_user ? current_user.id : nil
        ExportFilesJob.perform_later(repo_id,
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

  def unverified_email
    repo_id = new_params.require(:id)
    @email = ActionController::Base.helpers.sanitize(params.permit(:email)[:email])
    code = SecureRandom.hex(6)
    EmailVerification.create(email: @email, code: code)
    verification_token = encode_verification_token(@email, code)
    verification_url = "https://#{Rdr.host_name}/export_files/#{repo_id}?token=#{verification_token}"
    ExportFilesEmailVerificationMailer.with(email_address: @email, repo_id: repo_id, verification_url: verification_url)
                                                                                  .send_verification_email.deliver_now
  end

  private

  def new_params
    params.permit(:id, :login, :token)
  end

  def create_params
    params.permit(:basename, :confirmed, :email, :id)
  end

  def decode_verification_token(token)
    Base64.urlsafe_decode64(token)
  end

  def encode_verification_token(email, code)
    Base64.urlsafe_encode64("#{email}|#{code}")
  end

  def validate_token(token)
    email, code = decode_verification_token(token).split('|')
    verification_matches = EmailVerification.where(email: email, code: code)
    if verification_matches.empty?
      raise Rdr::InvalidEmailVerificationToken, I18n.t('rdr.batch_export.email_verification.invalid_token_error',
                                                      token: token)
    else
      verification_matches.destroy_all
      email
    end
  end

end
