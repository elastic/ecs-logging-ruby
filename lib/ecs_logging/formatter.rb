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

module EcsLogging
  class Formatter
    def call(severity, time, progname, msg, **extras)
      base = {
        "@timestamp": time.utc.iso8601(3),
        "log.level": severity,
        "message": msg,
        "ecs.version": "1.4.0"
      }

      base['log.logger'] = progname if progname

      base.merge!(extras) if extras

      JSON.fast_generate(base) + "\n"
    end
  end
end
