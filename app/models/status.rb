class Status
  include ActiveModel::Model

  OK = "OK"
  ERROR = "ERROR"

  attr_reader :meta, :services, :status

  ServiceReport = Struct.new(:status, :data, :error, keyword_init: true) do
    def error?
      status == ERROR
    end
  end

  class_attribute :solr_status_uri

  if ENV["SOLR_URL"].present?
    self.solr_status_uri = URI(ENV["SOLR_URL"]).tap do |u|
      u.path += "/admin/ping"
    end
  end

  def initialize
    @meta = _meta
    @services = _services
    @status = services.values.any?(&:error?) ? ERROR : OK
  end

  def _meta
    {
      timestamp: DateTime.now.iso8601,
      software: "rdr #{Rdr::VERSION}",
    }
  end

  def _services
    { database: database, jobs: jobs }.tap do |svcs|
      svcs[:index] = index if solr_status_uri
    end
  end

  def database
    stat, err = db_connection
    ServiceReport.new(
      status: stat,
      data: { adapter: "postgresql" },
      error: err
    )
  end

  def db_connection
    ActiveRecord::Base.connection && OK
  rescue PG::ConnectionBad => e
    [ ERROR, e.message ]
  end

  def jobs

    data, err = resque? ? resque : {}
    data.merge!(adapter: ActiveJob::Base.queue_adapter.class)
    ServiceReport.new(
      status: err ? ERROR : OK,
      data: data,
      error: err
    )
  end

  def resque?
    ActiveJob::Base.queue_adapter.is_a? ActiveJob::QueueAdapters.lookup(:resque)
  end

  def resque
    {
      queues: Resque.queue_sizes,
      info: Resque.info,
      dead_workers: Resque::Worker.all_workers_with_expired_heartbeats.length,
    }
  rescue Redis::BaseConnectionError => e
    [ {}, e.message ]
  end

  def index
    stat, err = solr
    ServiceReport.new(
      status: stat,
      error: err
    )
  end

  def solr
    JSON.parse(solr_response.body)["status"]
  rescue Net::HTTPServerError => e
    [ ERROR, e.message ]
  end

  def solr_response
    Net::HTTP.start(solr_status_uri.host, solr_status_uri.port, use_ssl: solr_ssl) do |http|
      http.request(solr_request)
    end
  end

  def solr_request
    Net::HTTP::Get.new(solr_status_uri).tap do |req|
      req.basic_auth(solr_status_uri.user, solr_status_uri.password) if solr_status_uri.user.present?
    end
  end

  def solr_ssl
    solr_status_uri.scheme == "https"
  end

end
