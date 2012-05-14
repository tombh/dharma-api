class Speaker
  include MongoMapper::Document

  key :name, String, :required => true
  key :bio, String
  key :website, String
  key :picture, String

  many :talks

  # Depends on mongmapper_plugins gem
  auto_increment_id

end

class Talk
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :permalink, String, :required => true
  key :duration, Integer # in seconds
  key :date, Date
  key :description, String
  key :venue, String
  key :event, String

  belongs_to :speaker
  key :speaker_id, ObjectId

  # Depends on mongmapper_plugins gem
  auto_increment_id

end
