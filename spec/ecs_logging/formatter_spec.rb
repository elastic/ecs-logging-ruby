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
require "ecs_logging/formatter"

module EcsLogging
  RSpec.describe Formatter do
    let(:time) { Time.utc(2026, 3, 4, 12, 0, 0) }
    
    it "formats a basic message" do
      result = subject.call("INFO", time, nil, "hello")
      json = JSON.parse(result)
      
      expect(json).to eq({
        "@timestamp" => "2026-03-04T12:00:00.000Z",
        "log.level" => "INFO",
        "message" => "hello",
        "ecs.version" => "8.11.0"
      })
    end

    it "includes progname as log.logger" do
      result = subject.call("INFO", time, "my-app", "hello")
      json = JSON.parse(result)
      expect(json["log.logger"]).to eq "my-app"
    end

    it "merges extras" do
      result = subject.call("INFO", time, nil, "hello", custom: "value", nested: { a: 1 })
      json = JSON.parse(result)
      expect(json["custom"]).to eq "value"
      expect(json["nested"]).to eq({ "a" => 1 })
    end
    
    it "adds a newline at the end" do
      result = subject.call("INFO", time, nil, "hello")
      expect(result).to end_with("\n")
    end
  end
end
