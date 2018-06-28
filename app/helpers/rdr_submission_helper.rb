module RdrSubmissionHelper

  def include_submission_entry?(submission, field)
    submission.send(field).present?
  end

  def submission_entry(submission, field)
    label = t("rdr.submissions.email.label.#{field}")
    "#{label}: #{submission.send(field)}"
  end

  def submission_folder_url(folder_id)
    "#{Rdr.box_base_url_rdr_submissions}/folder/#{folder_id}"
  end

end
