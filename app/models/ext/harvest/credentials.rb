module Harvest
  class Credentials
    attr_accessor :subdomain, :ssl
    
    def initialize(subdomain, ssl = true)
      @subdomain, @ssl = subdomain, ssl
    end
    
    def valid?
      !subdomain.nil?
    end
    
    def basic_auth
    end

    def build_path(path)
      path
    end

    def headers
      {}
    end
    
    def host
      "#{ssl ? "https" : "http"}://#{subdomain}.harvestapp.com"
    end
  end
  class PasswordCredentials < Credentials
    attr_accessor :username, :password
    
    def initialize(subdomain, username, password, ssl = true)
      super(subdomain, ssl)
      @username, @password = username, password
    end
    
    def valid?
      super && !username.nil? && !password.nil?
    end
    
    def basic_auth
      Base64.encode64("#{username}:#{password}").delete("\r\n")
    end
    def headers
      {"Authorization" => "Basic #{basic_auth}"}
    end
  end

  class TokenCredentials < Credentials
    attr_accessor :token
    
    def initialize(subdomain, token, ssl = true)
      super(subdomain, ssl)
      @token = token
    end
    
    def valid?
      super && !token.nil?
    end

    def build_path(path)
      "#{super(path)}?access_token=#{CGI::escape(token)}"
    end
  end
end