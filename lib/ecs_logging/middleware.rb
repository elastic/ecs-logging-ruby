# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# frozen_string_literal: true

require 'ecs_logging/logger'
require 'ecs_logging/body_proxy'

module EcsLogging
  class Middleware
    def initialize(app, logdev)
      @app = app
      @logger = Logger.new(logdev)
    end

    def call(env)
      status, headers, body = @app.call(env)
      body = BodyProxy.new(body) { log(env, status, headers) }
      [status, headers, body]
    end

    private

    def log(env, status, headers)
      req_method = env['REQUEST_METHOD']
      path = env['PATH_INFO']
      message = "#{req_method} #{path}"

      severity = status >= 500 ? Logger::ERROR : Logger::INFO

      extras = {
        client: { address: env["REMOTE_ADDR"] },
        http: { request: { method: req_method } },
        url: {
          domain: env['HTTP_HOST'],
          path: path,
          port: env['SERVER_PORT'],
          scheme: env['HTTPS'] == 'on' ? 'https' : 'http'
        }
      }

      if content_length = env["CONTENT_LENGTH"]
        extras[:http][:request][:'body.bytes'] = content_length
      end

      if user_agent = env['HTTP_USER_AGENT']
        extras[:user_agent] = { original: user_agent }
      end

      @logger.add(severity, message, **extras)
    end
  end
end

