class DeactivateArk

  attr_reader :ark

  def self.call(ark)
    new(ark).call
  end

  def initialize(ark)
    @ark = Ark.new(nil, ark)
  end

  def call
    if ark.reserved?
      ark.delete!
    elsif ark.public?
      ark.deactivate!
    end
  end

end
