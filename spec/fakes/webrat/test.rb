module Webrat #:nodoc:
  def self.session_class #:nodoc:
    case Webrat.configuration.mode
    when :selenium
      SeleniumSession
    else 
      TestSession
    end
  end

  class TestSession < Session #:nodoc:
    attr_accessor :response_body
    attr_writer :response_code

    def doc_root
      File.expand_path(File.join(".", "public"))
    end

    def response
      @response ||= Object.new
    end

    def response_code
      @response_code || 200
    end

    def get(url, data, headers = nil)
    end

    def post(url, data, headers = nil)
    end

    def put(url, data, headers = nil)
    end

    def delete(url, data, headers = nil)
    end
  end
end
