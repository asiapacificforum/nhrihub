require 'digest/sha1'
class AccessNonce
  def self.create
    # offset the timestamp so that many can be created in very short time without activation_code collisions
    Digest::SHA1.hexdigest( Time.now.advance(:seconds => rand(1000000)).to_s.split(//).sort_by {rand}.join )
  end
end
