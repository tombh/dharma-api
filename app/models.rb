class Speaker
	include MongoMapper::Document

	key :name, String, :required => true
	key :bio, String
	key :website, String
	key :picture, String

	many :talks

end

class Talk
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :permalink, String, :required => true
  key :duration, String # in seconds
  key :date, Time
  key :description, String
  key :venue, String
  key :event, String

  belongs_to :speaker
  key :speaker_id, ObjectId

  def to_hash
    hash = {}
    instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
  end
  
end
