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

require "logger"
require "ecs_logging/formatter"

module EcsLogging
  class Logger < ::Logger
    def initialize(*args)
      super
      self.formatter = Formatter.new
    end

    def add(severity, message = nil, progname = nil, **extras)
      severity ||= UNKNOWN

      return true if @logdev.nil? or severity < level
      progname = @progname if progname.nil?

      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @progname
        end
      end

      @logdev.write(
        format_message(
          format_severity(severity),
          Time.now,
          progname,
          message,
          **extras
        )
      )

      true
    end

    def info(progname, **extras, &block)
      add(INFO, nil, progname, **extras, &block)
    end

    private

    def format_message(severity, datetime, progname, msg, **extras)
      formatter.call(severity, datetime, progname, msg, **extras)
    end
  end
end
