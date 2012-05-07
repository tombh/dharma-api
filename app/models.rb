class Speaker
	include MongoMapper::Document

	key :name, String, :required => true
	key :bio, String

	many :talks

end

class Talk
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :permalink, String, :required => true
  key :duration, Integer # in seconds

  belongs_to :speaker
end
