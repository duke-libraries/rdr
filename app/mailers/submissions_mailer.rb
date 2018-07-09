class SubmissionsMailer < ApplicationMailer

  helper :rdr_submission

  def notify_error(submission)
    @submission = submission
    subject = I18n.t('rdr.submissions.email.error.subject')
    to = Rdr.curation_group_email
    from = Rdr.curation_group_email
    mail(to: to, from: from, subject: subject)
  end

  def notify_screened_out(submission)
    @submission = submission
    subject = I18n.t('rdr.submissions.email.screened_out.subject')
    to = Rdr.curation_group_email
    from = Rdr.curation_group_email
    mail(to: to, from: from, subject: subject)
  end

  def notify_success(submission, submission_folder)
    @submission = submission
    @submission_folder = submission_folder
    subject = I18n.t('rdr.submissions.email.success.subject')
    to = [ submission.submitter.email, Rdr.curation_group_email ]
    from = Rdr.curation_group_email
    mail(to: to, from: from, subject: subject)
  end

end
