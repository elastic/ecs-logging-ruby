## Licensed to Elasticsearch B.V. under one or more contributor
## license agreements. See the NOTICE file distributed with
## this work for additional information regarding copyright
## ownership. Elasticsearch B.V. licenses this file to you under
## the Apache License, Version 2.0 (the "License"); you may
## not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##   http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing,
## software distributed under the License is distributed on an
## "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
## KIND, either express or implied.  See the License for the
## specific language governing permissions and limitations
## under the License.

## frozen_string_literal: true

#require 'rack/test'
#require 'sinatra/base'

#require 'rack/ecs_logger'

#class CaptureLogger
#  def initialize
#    clear!
#  end

#  def clear!
#    @messages = []
#  end

#  attr_reader :messages

#  def write(args)
#    @messages.push(args)
#  end
#end

#module Rack
#  RSpec.describe EcsLogger do
#    include Rack::Test::Methods

#    def app
#      MyApp
#    end

#    TestLogger = CaptureLogger.new

#    before :all do
#      class MyApp < Sinatra::Base
#        use EcsLogger, TestLogger

#        get '/' do
#          'ok'
#        end
#      end
#    end

#    before :each do
#      TestLogger.clear!
#    end

#    it 'logs GET requests' do
#      resp = get '/'

#      expect(TestLogger.messages.count).to be 1

#      json = JSON.parse(TestLogger.messages.last)

#      expect(json).to match(
#        '@timestamp' => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/,
#        'log.level' => "info",
#        'message' => "GET /",
#        'ecs.version' => '1.4.0',
#        'http' => {
#          'request' => {
#            'method' => 'GET'
#          }
#        },
#        'url' => {
#          'domain' => 'example.org',
#          'path' => '/',
#          'port' => '80',
#          'scheme' => 'http'
#        }
#      )
#    end

#    it 'validates against schema' do
#      get '/'

#      schema = JSON.parse(::File.read('spec/fixtures/spec/spec.json'))
#      log_json = JSON.parse(TestLogger.messages.last)
#      expect { JSON::Validator.validate!(schema, log_json) }.to_not raise_error
#    end
#  end
#end
