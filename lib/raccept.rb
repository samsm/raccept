require 'json'

# This will require active-support and enhance it so more objects can tbe to_xml'd
require File.dirname(__FILE__) + '/../vendor/xml_serialization/lib/xml_serialization'

class Raccept
  attr_reader :app
  def initialize(app, options = {})
    @app = app
  end

  def call(env)
    result = app.call(env)
    body = result[2]

    # If body is already a string or array with string(s) pass it along.
    return result if legal_rack_body?(body)

    accepts_headers = env['HTTP_ACCEPT'].sub(/\;.+/,'').split(',')
    accepts_headers.each do |accepts|
      if header_list[accepts]
        return [result[0],
                result[1],
                convert(header_list[accepts], body)
               ]
      end
    end
    result # apparently nothing matched, so return untouched result
  end

  def legal_rack_body?(body)
    if body.kind_of?(String)
      true
    elsif body.respond_to?(:each)
      body.collect {|element| element.class }.uniq == [String]
    end
  end

  def convert(format, body)
    case format
    when :json
      body.to_json
    when :xml
      body.to_xml
    end
  end

  def header_list
    {
      'application/json' => :json,
      'text/json'        => :json,
      'application/xml'  => :xml,
      'text/xml'         => :xml
    }
  end

end