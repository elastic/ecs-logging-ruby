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

require 'json'

class SpecValidator
  class RequiredFieldMissingError < StandardError; end
  class WrongIndexError < StandardError; end
  class TypeError < StandardError; end

  def initialize(spec)
    @spec = spec
  end

  attr_reader :spec

  def validate!(json)
    spec.fetch('fields').each_with_index do |(field_name, field_spec), index|
      log_value = json[field_name]

      if field_spec.fetch('required', false) && log_value.nil?
        raise RequiredFieldMissingError, "Missing required field `#{field_name}`"
      end

      if (spec_index = field_spec['index']) && spec_index != index
        raise WrongIndexError, "Expected field `#{field_name}` at index #{spec_index}, was #{index}"
      end

      next unless log_value

      validateType(field_name, field_spec, log_value)
    end

    true
  end

  private

  def validateType(field_name, field_spec, log_value)
    return true unless (spec_type = field_spec['type'])

    case spec_type
    when 'datetime'
      raise TypeError, 'Invalid datetime' unless DateTime.parse(log_value)
    when 'string'
      unless log_value.is_a?(String)
        raise TypeError, "Expected string for '#{field_name}', got #{log_value.inspect}"
      end
    when 'object'
    else
      raise ArgumentError, "Unknown spec type '#{spec_type}'"
    end
  end
end
