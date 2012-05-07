
# Nokogiri's #css method returns a nil class if it can't find anything. 
# This is differnt from jQuery where you can still call methods on empty objects
# without incurring any errors. So to save having to check each Nokogiri::Node#css call before
# interrogating for more info, we can catch the exception, attribute null to that
# particular Talk property and move on with our lives.
# But we don't want a catch-all exception that just bails on the entire Talk, rather
# we want to individually catch exceptions. So we put each property in this hash
# and iterate over each item looking for an exception.
# If the item is an array then the proceeding block will operate on it with a [0],
# it will assume that it is ready to be persisted.
class Nokogiri::XML::Node

	def tolerant_css(selector, attribute = nil)
		node = css(selector).first
		if node
			if attribute
				return node.attr(attribute) 
			else
				return node.text
			end
		else
			return nil
		end
	end
end