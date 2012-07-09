require 'digest'

class Speaker
  include MongoMapper::Document
  safe # Raises an error, in situations such as duplicates

  key :name, String, :required => true, :unique => true
  key :bio, String
  key :website, String
  key :picture, String

  many :talks

  # Depends on mongmapper_plugins gem
  auto_increment_id
end

class Talk
  include MongoMapper::Document
  safe
  
  key :title, String, :required => true
  key :permalink, String, :required => true, :unique => true
  key :duration, Integer # in seconds
  key :date, Date
  key :description, String
  key :venue, String
  key :event, String
  key :source, String
  key :license, String

  belongs_to :speaker
  key :speaker_id, ObjectId

  auto_increment_id
end

class Key
  include MongoMapper::Document
  safe

  key :api_key, String
  key :email, String
  key :status, String

  def self.email_token email
    return false unless !email.nil?
    key = self.find_by_email(email)
    if !key 
      api_key = Digest::MD5.hexdigest(Time.now.to_s)
      self.create({
        :api_key => api_key,
        :email => email,
        :status => 'active'
      })
      subject = "Dharma API key"
    else
      api_key = key.api_key
      subject = "Dharma API key reminder"
    end
    email_text = open(PROJECT_ROOT + '/app/api_request_email.txt').read
    mail = Mail.new do
      to email
      from "Dharma API <admin@tombh.co.uk>"
      subject subject
      body email_text.gsub('#{api_key}', api_key)
    end
    mail.deliver!
  end
end
