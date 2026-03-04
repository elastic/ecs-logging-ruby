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

    def add(severity, message = nil, progname = nil, include_origin: false, **extras)
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

      if apm_agent_present_and_running?
        if txn = ElasticAPM.current_transaction
          extras[:"transaction.id"] = txn.id
          extras[:"trace.id"] = txn.trace_id
        end
        if span = ElasticAPM.current_span
          extras[:"span.id"] = span.id
        end
      end

      @logdev.write(
        format_message(
          format_severity(severity),
          Time.now,
          progname,
          message,
          extras
        )
      )

      true
    end

    %w[unknown fatal error warn info debug].each do |severity|
      define_method(severity) do |progname = nil, include_origin: false, **extras, &block|
        if include_origin && origin = origin_from_caller(caller_locations(1, 1))
          extras[:"log.origin"] = origin
        end

        name = severity.upcase.to_sym
        cnst = self.class.const_get(name)
        add(cnst, nil, progname, include_origin: include_origin, **extras, &block)
      end
    end

    private

    def origin_from_caller(locations)
      return unless location = locations&.first

      {
        'file.name': File.basename(location.path),
        'file.line': location.lineno,
        function: location.label
      }
    end

    def format_message(severity, datetime, progname, msg, extras = nil)
      formatter.call(severity, datetime, progname, msg, extras)
    end

    def apm_agent_present_and_running?
      @apm_present ||= defined?(::ElasticAPM)
      return false unless @apm_present

      ElasticAPM.running?
    end
  end
end
