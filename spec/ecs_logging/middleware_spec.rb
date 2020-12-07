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

require 'ecs_logging/middleware'

module EcsLogging
  RSpec.describe Middleware do
    include Rack::Test::Methods

    def app
      MyApp
    end

    TestIO = StringIO.new

    before :all do
      class MyApp < Sinatra::Base
        use EcsLogging::Middleware, TestIO

        disable :show_exceptions

        get '/' do
          'ok'
        end
      end
    end

    let(:log) { TestIO.rewind; TestIO.read }

    it 'logs GET requests' do
      resp = get '/'

      expect(resp.body).to eq 'ok'
      expect(log.lines.count).to be 1

      json = JSON.parse(log.lines.last)

      expect(json).to match(
        '@timestamp' => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/,
        'log.level' => "INFO",
        'message' => "GET /",
        'ecs.version' => '1.4.0',
        'client' => { 'address' => '127.0.0.1' },
        'http' => {
          'request' => {
            'method' => 'GET',
            'body.bytes' => '0'
          }
        },
        'url' => {
          'domain' => 'example.org',
          'path' => '/',
          'port' => '80',
          'scheme' => 'http'
        }
      )
    end

    it 'ensures key order' do
      resp = get '/'
      json = JSON.parse(log.lines.last)

      expect(json.keys.first(4)).to eq %w[@timestamp log.level message ecs.version]
    end
  end
end
