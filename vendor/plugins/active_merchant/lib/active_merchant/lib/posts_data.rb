module ActiveMerchant #:nodoc:
  module PostsData  #:nodoc:
    
    def self.included(base)
      base.class_inheritable_accessor :ssl_strict
      base.ssl_strict = true
    end
    
    def ssl_post(url, data, headers = {})
      uri   = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port) 
      http.use_ssl        = true
      
      if self.class.ssl_strict
        http.verify_mode    = OpenSSL::SSL::VERIFY_PEER
        http.ca_file        = File.dirname(__FILE__) + '/../../certs/cacert.pem'
      else
        http.verify_mode    = OpenSSL::SSL::VERIFY_NONE
      end
      
      if @options && !@options[:pem].blank?
        http.cert           = OpenSSL::X509::Certificate.new(@options[:pem])
        http.key            = OpenSSL::PKey::RSA.new(@options[:pem])
      end
      
      http.post(uri.request_uri, data, headers).body
    end    
  end
end
