# We're quite often fine about putting null values in the db, so why throw errors all the time!?

# Nokogiri's #css method returns a nil class if it can't find anything. 
# This is differnt from jQuery where you can still call methods on empty objects
# without incurring any errors. This tolerant_css method does a few things;
# It assumes your selector is drilling down to find only one element and tries
# to return that element's contents by default. But you can also specify an
# attribute if you want the 'href', 'src', etc
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