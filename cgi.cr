require "http/server"

class CGIHandler
    include HTTP::Handler

    def call(context)
        path = "." + context.request.path
        if path =~ %r{^./cgi} && File.executable?(path)
            Process.run(
                path,
                env: {
                    "CONTENT_LENGTH" => "#{context.request.content_length}",
                    "CONTENT_TYPE" => "#{context.request.headers.fetch("Content-Type", "text/plain")}",
                    "QUERY_STRING" => "#{context.request.query_params}",
                    "REQUEST_METHOD" => "#{context.request.method}",
                },
                input: context.request.body || Process::Redirect::Close,
                output: context.response
            )
        else
            call_next(context)
        end
    end
end
