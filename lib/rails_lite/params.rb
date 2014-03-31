require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = {}
    unless req.query_string.nil?
      parse_www_encoded_form(req.query_string)
    end
    route_params.each do |k,v|
      @params[k] = v
    end
    unless req.body.nil?
      parse_www_encoded_form(req.body)
    end
  end

  def [](key)
    @params[key]
  end

  def []=(key,value)
    @params[key] = value
  end

  def permit(*keys)
    @permitted_keys = keys.to_s
  end

  def require(key)
    raise AttributeNotFoundError unless @params.include?(key)
  end

  def permitted?(key)
    return true if @permitted_keys.include?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    URI.decode_www_form(www_encoded_form).each do |key, value|
      keys = parse_key(key)
      last_param = {}
      next_param = @params
      (0...keys.length - 1).each do |i|
        key = keys[i]
        unless next_param[key]
          next_param[key] = {}
        end
        next_param = next_param[key] 
      end
      next_param[keys.last] = value
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end

