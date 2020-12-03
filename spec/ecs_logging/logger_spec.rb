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

require "spec_helper"
require "ecs_logging/logger"

module EcsLogging
  RSpec.describe Logger do
    let(:io) { StringIO.new }
    let(:log) { io.rewind; io.read }

    subject { described_class.new(io) }

    it "logs in ECS format" do
      subject.info("very informative")

      json = JSON.parse(log)

      expect(json).to match(
        "@timestamp" => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/,
        "log.level" => "INFO",
        "message" => "very informative",
        "ecs.version" => "1.4.0",
      )
    end

    it "has methods for all severities" do
      subject.unknown('ok', process: { id: 1 })
      subject.fatal('ok', process: { id: 1 })
      subject.error('ok', process: { id: 1 })
      subject.warn('ok', process: { id: 1 })
      subject.info('ok', process: { id: 1 })
      subject.debug('ok', process: { id: 1 })

      expect(log.lines.count).to be 6
    end

    it "adds extra keys" do
      subject.info("ok", process: { id: 1 })

      json = JSON.parse(log)

      expect(json).to match(
        "@timestamp" => String,
        "log.level" => "INFO",
        "message" => "ok",
        "ecs.version" => "1.4.0",
        "process" => { "id" => 1 }
      )
    end

    describe "with progname" do
      it "includes it" do
        subject.info("yes") { "ok" }

        json = JSON.parse(log)

        expect(json["log.logger"]).to eq "yes"
      end
    end

    describe 'include_origin:' do
      it 'includes origin fields' do
        subject.info("very informative", include_origin: true)

        json = JSON.parse(log)

        expect(json).to match(
          "@timestamp" => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/,
          "log.level" => "INFO",
          "message" => "very informative",
          "ecs.version" => "1.4.0",
          "log.origin" => {
            "file.line" => Integer,
            "file.name" => "logger_spec.rb",
            "function" => /block.*in.*EcsLogging/
          }
        )
      end
    end
  end
end
