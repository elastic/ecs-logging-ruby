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

require 'rack/test'
require 'sinatra/base'

module Rack
  class BodyProxy
    def initialize(body, &block)
      @body = body
      @block = block
      @closed = false
    end

    def respond_to_missing?(name, include_all = false)
      super || @body.respond_to?(name, include_all)
    end

    def method_missing(name, *args, &block)
      @body.__send__(name, *args, &block)
    end

    def close
      return if closed?

      @closed = true

      begin
        @body.close if @body.respond_to?(:close)
      ensure
        @block.call
      end
    end

    def closed?
      @closed
    end
  end

  class EcsLogger
    def initialize(app, logger)
      @app = app
      @logger = logger
    end

    def call(env)
      status, headers, body = @app.call(env)
      body = BodyProxy.new(body) { log(env, status, headers) }
      [status, headers, body]
    end

    private

    def log(env, status, headers)
      msg = {
        '@timestamp': Time.now.utc.iso8601(3),
        log: {
          level: status >= 500 ? 'error' : 'info',
          logger: 'Rack'
        },
        http: {
        },
        ecs: { version: '1.7.0' }
      }
      @logger.write(JSON.fast_generate(msg))
    end
  end
end

class CaptureLogger
  def initialize
    @messages = []
  end

  attr_reader :messages

  def write(args)
    @messages.push(args)
  end
end

module Rack
  RSpec.describe EcsLogger do
    include Rack::Test::Methods

    def app
      MyApp
    end

    TestLogger = CaptureLogger.new

    before :all do
      class MyApp < Sinatra::Base
        use EcsLogger, TestLogger

        get '/' do
          'ok'
        end
      end
    end

    it 'logs GET requests' do
      resp = get '/'

      expect(TestLogger.messages.count).to be 1

      log, = TestLogger.messages
      json = JSON.parse(log)

      expect(json).to match(
        '@timestamp' => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z/,
        'ecs' => { 'version' => '1.7.0' },
        'http' => {},
        'log' => { 'level' => 'info', 'logger' => 'Rack' }
      )

      pp TestLogger.messages
    end
  end
end
