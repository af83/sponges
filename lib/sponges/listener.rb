# encoding: utf-8
module Sponges
  class Listener
    attr_reader :supervisor
    CRLF = "\r\n"

    def initialize(supervisor)
      @supervisor = supervisor
    end

    def call
      Socket.tcp_server_loop("0.0.0.0", port) {|c| handle_connection c }
    end

    private

    def port
      Sponges::Configuration.port
    end

    def handle_connection(connection)
      response = Response.new(supervisor).to_json
      connection.write headers(response)
      connection.write response
      connection.close_write
      connection.close_read
    rescue SystemCallError
      # Resist to system errors when closing or writing to a socket that is not
      # opened.
    end

    def headers(response)
      [
        "HTTP/1.1 200 OK",
        "Date: #{Time.now.utc}",
        "Status: OK",
        "Server: Sponges #{Sponges::VERSION} #{supervisor.name} edition",
        "Content-Type: application/json; charset=utf-8",
        "Content-Length: #{response.length}",
        CRLF
      ].join(CRLF)
    end

  end
end
