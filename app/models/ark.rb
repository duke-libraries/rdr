require 'ezid-client'

class Ark

  class Error < Rdr::Error; end
  class AssignmentFailed < Error; end
  class RepoObjectNotPersisted < Error; end
  class AlreadyAssigned < AssignmentFailed; end
  class IdentifierNotAssigned < Error; end
  class IdentifierNotFound < Error; end

  DEFAULT_STATUS  = Ezid::Status::RESERVED
  DEFAULT_EXPORT  = 'no'.freeze
  DEFAULT_PROFILE = 'dc'.freeze

  class_attribute :identifier_class

  self.identifier_class = Ezid::Identifier
  self.identifier_class.defaults = {
      profile: DEFAULT_PROFILE,
      export: DEFAULT_EXPORT,
      status: DEFAULT_STATUS
  }

  def self.assign!(repo_object_or_id, identifier_or_id = nil)
    new(repo_object_or_id, identifier_or_id).assign!
  end

  def self.assigned(repo_object_or_id)
    ark = new(repo_object_or_id)
    ark.assigned? ? ark : nil
  end

  def initialize(repo_object_or_id, identifier_or_id = nil)
    case repo_object_or_id
      when ActiveFedora::Base
        raise RepoObjectNotPersisted, 'Repository object must be persisted.' if repo_object_or_id.new_record?
        @repo_object = repo_object_or_id
      when String, nil
        @repo_id = repo_object_or_id
      else
        raise TypeError, "#{repo_object_or_id.class} is not expected as the first argument."
    end
    case identifier_or_id
      when identifier_class
        @identifier = identifier_or_id
      when String, nil
        @identifier_id = identifier_or_id
      else
        raise TypeError, "#{identifier_or_id.class} is not expected as the second argument."
    end
  end

  def repo_object
    @repo_object ||= ActiveFedora::Base.find(repo_id)
  end

  def repo_id
    @repo_id ||= @repo_object && @repo_object.id
  end

  def assign!(id = nil)
    if assigned?
      raise AlreadyAssigned,
            "Repository object \"#{repo_object.id}\" has already been assigned ark \"#{repo_object.ark}\"."
    end
    @identifier = case id
                    when identifier_class
                      id
                    when String
                      find_identifier(id)
                    when nil
                      mint_identifier
                  end
    repo_object.reload
    repo_object.ark = identifier.id
    repo_object.save!
  end

  def assigned?
    repo_object.ark.present?
  end

  def publish!
    public!
    save
  end

  def identifier
    if @identifier.nil?
      if identifier_id
        @identifier = find_identifier(identifier_id)
      elsif assigned?
        @identifier = find_identifier(repo_object.ark)
      end
    end
    @identifier
  end

  def identifier_id
    @identifier_id ||= @identifier && @identifier.id
  end

  protected

  def method_missing(name, *args, &block)
    identifier.send(name, *args, &block)
  end

  private

  def find_identifier(ark)
    identifier_class.find(ark)
  rescue Ezid::IdentifierNotFoundError => e
    raise IdentifierNotFound, e.message
  end

  def mint_identifier(*args)
    identifier_class.mint(*args)
  end

end
