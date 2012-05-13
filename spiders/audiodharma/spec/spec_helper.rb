require_relative './../../../spec/spec_helper'
require_relative './../../init'
require_relative './../spider'

# Override the open_speaker_doc method so that it uses the sample speaker fixture,
# rather than running off to the open web where things can change wthout warning :(
class Dharmaseed
  def open_speaker_doc(url)
    open( File.dirname(__FILE__) + '/fixtures/speaker_sample.html')
  end
end