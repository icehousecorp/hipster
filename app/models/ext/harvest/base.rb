module Harvest
  class Base
    def initialize(credentials, options = {})
      options[:ssl] = true if options[:ssl].nil?
      @credentials = credentials
      raise InvalidCredentials unless credentials.valid?
    end
  end
  
  class << self
    def client(subdomain, username, password, options = {})
      credentials = PasswordCredentials.new(subdomain, username, password, options[:ssl])
      Harvest::Base.new(credentials, options)
    end

    def token_client(subdomain, token, options = {})
      credentials = TokenCredentials.new(subdomain, token, options[:ssl])
      Harvest::Base.new(credentials, options)
    end

    def hardy_token_client(subdomain,token, options = {})
      retries = options.delete(:retry)
      Harvest::HardyClient.new(token_client(subdomain, token, options), (retries || 5))
    end

    def hardy_client(subdomain, username, password, options = {})
      retries = options.delete(:retry)
      Harvest::HardyClient.new(client(subdomain, username, password, options), (retries || 5))
    end
  end
end
