# encoding: utf-8
require 'net/http'

module ArtTypograf

  class NetworkError < StandardError
    def initialize(message="", backtrace = nil)
      super(message)
      self.set_backtrace(backtrace) if backtrace
    end
  end

  class Client
    URL = 'http://typograf.artlebedev.ru/webservices/typograf.asmx'
    DEFAULT_PREFERENCES = {
      :entity_type => :no,
      :use_br => true,
      :use_p => true,
      :max_nobr => 3
      # :encoding => 'UTF-8'
    }
    RESULT = /<ProcessTextResult>\s*((.|\n)*?)\s*<\/ProcessTextResult>/m

    def check_options(options)
      o = options.dup

      [:use_br, :use_p].each do |key|
        val = o[key]
        o[key] = case val
          when true  then 1
          when false then 0
          when 0, 1  then val
          else raise ArgumentError, "Unknown #{key}: #{val}"
        end
      end

      o[:entity_type] = case o[:entity_type]
        when :html  then 1
        when :xml   then 2
        when :no    then 3
        when :mixed then 4
        when 1..4   then o[:entity_type]
        else raise ArgumentError, "Unknown entity_type: #{o[:entity_type]}"
      end

      o
    end

    def form_xml(text, options)
      o = options
      xml = <<-SOAP_TEMPLATE
<?xml version="1.0" encoding="UTF-8" ?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
 <ProcessText xmlns="http://typograf.artlebedev.ru/webservices/">
  <text>#{text.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;')}</text>
     <entityType>#{o[:entity_type]}</entityType>
     <useBr>#{o[:use_br]}</useBr>
     <useP>#{o[:use_p]}</useP>
     <maxNobr>#{o[:max_nobr]}</maxNobr>
  </ProcessText>
 </soap:Body>
</soap:Envelope>
SOAP_TEMPLATE
      xml.gsub(/^\s|\s$/, '')
    end

    def initialize(options = {})
      @url = URI.parse(options.delete(:url) || URL)
      @options = check_options( DEFAULT_PREFERENCES.dup.merge(options) )
    end

    # Process text with remote web-service
    def send_request(text)
      begin
        request = Net::HTTP::Post.new(@url.path, {
          'Content-Type' => 'text/xml',
          'SOAPAction' => '"http://typograf.artlebedev.ru/webservices/ProcessText"'
        })
        request.body = form_xml(text, @options)

        response = Net::HTTP.new(@url.host, @url.port).start do |http|
          http.request(request)
        end
      rescue StandardError => exception
        raise NetworkError.new(exception.message, exception.backtrace)
      end

      if !response.is_a?(Net::HTTPOK)
        raise NetworkError, "#{response.code}: #{response.message}"
      end

      if RESULT =~ response.body
        body = $1.gsub(/&gt;/, '>').gsub(/&lt;/, '<').gsub(/&amp;/, '&')
        body.force_encoding("UTF-8").chomp
      else
        raise NetworkError, "Can't match result #{response.body}"
      end
    end
  end
end
