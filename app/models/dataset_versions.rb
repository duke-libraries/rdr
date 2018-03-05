require 'delegate'

class DatasetVersions < SimpleDelegator

  attr_reader :base

  def initialize(base)
    @base = base
    super([ base ])
    add_previous_versions
    add_later_versions
  end

  def latest_version
    last
  end

  def add_previous_versions
    v = base
    while v.has_previous_dataset_version?
      v = v.previous_dataset_version
      unshift v
    end
  end

  def add_later_versions
    v = base
    while v.has_next_dataset_version?
      v = v.next_dataset_version
      push v
    end
  end

end
