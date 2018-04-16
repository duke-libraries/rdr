require 'curb'

class CrossrefRegistration

  REGISTRATION_PATH = "/servlet/deposit"

  class_attribute :uri
  self.uri = URI::HTTPS.build(host: Rdr.crossref_host,
                              path: REGISTRATION_PATH,
                              query: URI.encode_www_form(login_id: Rdr.crossref_user,
                                                         login_passwd: Rdr.crossref_password)
                             ).freeze

  Response = Struct.new(:status, :body)

  def self.call(work)
    new(work).call
  end

  attr_reader :work

  def initialize(work)
    @work = work
  end

  def call
    curl.post(fname_field)
    Response.new(curl.status, curl.body)
  end

  def fname_field
    Curl::PostField.file("fname", "crossref_metadata.xml") { |field| metadata.to_xml }
  end

  def curl
    @curl ||= Curl::Easy.new(uri.to_s) do |c|
      c.multipart_form_post = true
      c.on_redirect { |easy| registration_error(easy.body) }
      c.on_missing  { |easy| registration_error(easy.body) }
      c.on_failure  { |easy| registration_error(easy.body) }
    end
  end

  def metadata
    @metadata ||= CrossrefMetadata.call(work)
  end

  def registration_error(message)
    raise Rdr::CrossrefRegistrationError, message
  end

end
