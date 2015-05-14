module IERemoteDetector
  extend RSpec::Core::SharedContext

  def ie_remote?(page)
    !!page.evaluate_script("navigator.userAgent").match("Windows") # IE test on remote windows machine
  end
end
