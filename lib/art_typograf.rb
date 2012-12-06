require "art_typograf/version"
require "art_typograf/client"

module ArtTypograf
  def self.process(text, options = {})
    Client.new(options).send_request(text)
  end
end
