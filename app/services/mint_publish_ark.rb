class MintPublishArk

  attr_reader :ark

  def self.call(work)
    new(work).call
  end

  def initialize(work)
    @ark = Ark.new(work)
  end

  def call
    ark.assign! unless ark.assigned?
    ark.target! if ark.assigned?
    ark.publish! if ark.assigned? && !ark.public?
  end

end
