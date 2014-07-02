require 'uri'
require 'debugger'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = {}
    
    query_hash = {}
    if req.query_string 
      query_hash = parse_www_encoded_form(req.query_string)
    end
    
    @params.merge!(query_hash)
    if req.body
      @params.merge!(parse_www_encoded_form(req.body))
    end
    @params.merge!(route_params)
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted_keys ||= []
    @permitted_keys.concat(keys)
  end

  def require(key)
    raise Params::AttributeNotFoundError.new unless @params.keys.include?(key)
    @params[key]
  end

  def permitted?(key)
    @permitted_keys.include? key
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www)
  
    decoded = URI.decode_www_form(www)
    result = {}
  
    decoded.each do |key_pair|
      keys = key_pair.first
      value = key_pair.last
      keys = parse_key(keys)
      current_hash = result
    
      keys.each_with_index do |key,index|
        if keys.length - 1 == index
          current_hash[key] = value
        else
          current_hash[key] ||= {}
          current_hash = current_hash[key]
        end
      end
    end
    result
  end
  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end

end

