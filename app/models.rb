require 'digest'

# A person that gives a dharma talk
class Speaker
  include Mongoid::Document

  field :id
  field :name
  field :bio
  field :website
  field :picture

  alias_attribute :id, :_id

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :talks
end

# A dharma talk
class Talk
  include Mongoid::Document

  field :id
  field :title
  field :permalink
  field :duration, type: Integer # in seconds
  field :date, type: Date
  field :description
  field :venue
  field :event
  field :source
  field :license

  alias_attribute :id, :_id

  validates_presence_of :title
  validates_presence_of :permalink
  validates_uniqueness_of :permalink

  belongs_to :speaker
end

# An API key
class Key
  include Mongoid::Document

  field :api_key
  field :email
  field :status

  def self.email_token(email)
    return false if email.nil?

    begin
      key = find_by(email: email)
      api_key = key.api_key
      subject = 'Dharma API key reminder'
    rescue Mongoid::Errors::DocumentNotFound
      api_key = Digest::MD5.hexdigest(Time.now.to_s)
      create(
        api_key: api_key,
        email: email,
        status: 'active'
      )
      subject = 'Dharma API key'
    end

    email_text = open(PROJECT_ROOT + '/app/api_request_email.txt').read
    mail = Mail.new do
      to email
      from 'Dharma API <admin@tombh.co.uk>'
      subject subject
      body email_text.gsub('#{api_key}', api_key)
    end
    mail.deliver!
  end
end
