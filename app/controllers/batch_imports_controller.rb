class BatchImportsController < ApplicationController

  load_and_authorize_resource

  def create
    if @batch_import.valid?
      BatchImportJob.perform_later(manifest_file: @batch_import.manifest_file_full_path,
                                   files_directory: @batch_import.files_directory_full_path,
                                   model: @batch_import.model,
                                   checksum_file: @batch_import.checksum_file_full_path,
                                   on_behalf_of: @batch_import.on_behalf_of,
                                   user: current_user.user_key)
      render 'queued'
    else
      render 'new'
    end
  end

end
