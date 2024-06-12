require "http/server"
require "openssl"
require "option_parser"
require "colorize"
require "./cgi.cr"

##########################
## default/parse arguments
ip, port, dir = "127.0.0.1", 8080, "."
tls, cgi = false, false
tls_key, tls_cert = nil, nil
handlers = [HTTP::ErrorHandler.new, HTTP::LogHandler.new] of HTTP::Handler
before_parse = ARGV.size

parser = OptionParser.parse do |parser|
  parser.banner = "Simple HTTP(S) Server\n\nUsage: #{PROGRAM_NAME} #{"[OPTIONS]".colorize(:dark_gray)} IP:PORT"

  parser.on "-h", "--help", "Show this help" { puts parser; exit }
  parser.on "-s", "--tls", "Enable TLS" { tls = true }
  parser.on "-k KEY", "--key=KEY", "Specify the private key" { |k| tls_key = k }
  parser.on "-c CERT", "--cert=CERT", "Specify the certificate" { |c| tls_cert = c }
  parser.on "-d DIRECTORY", "--dir=DIRECTORY", "Serve the directory" { |d| dir = d }
  parser.on "--cgi", "Enable basic CGI support for files in /cgi" { cgi = true }

  parser.missing_option { |opt| abort "#{PROGRAM_NAME}: #{opt}: requires additional arguments\n#{parser}" }
  parser.invalid_option { |opt| abort "#{PROGRAM_NAME}: #{opt}: unknown argument\n#{parser}" }
end

##########################
## check arguments
abort parser, 0 if ARGV.size.zero? || before_parse.zero?
abort "ERROR: #{ARGV[0]} is in wrong format (expect IP:PORT)\n#{parser}" if ARGV[0] !~ /:/
abort "ERROR: key and cert are mendatory when using --tls.\n#{parser}" if tls && (tls_key.nil? || tls_cert.nil?)

ip, port = ARGV[0].split(':'); port = port.to_i
handlers << CGIHandler.new if cgi
handlers << HTTP::StaticFileHandler.new(dir)

##########################
## CTRL-C handler
Signal::INT.trap do
  puts "\rBye Bye :)"
  exit(0)
end

##########################
## setup and starts the server
server = HTTP::Server.new(handlers)
if tls && tls_key && tls_cert
    ctx = OpenSSL::SSL::Context::Server.from_hash({
        "key" => tls_key,
        "cert" => tls_cert
    })
    addr = server.bind_tls ip, port, ctx, reuse_port: true
    puts "Serving #{dir} on https://#{addr}"
else
    addr = server.bind_tcp ip, port, reuse_port: true
    puts "Serving #{dir} on http://#{addr}"
end
server.listen
