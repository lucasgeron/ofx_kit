# frozen_string_literal: true

require 'time'

module OFX
  class Configuration
    # Mixin included by {Base::Builder} to parse OFX date strings into +Time+ objects.
    # Handles the two formats found in OFX files (YYYYMMDD and YYYYMMDDHHMMSS),
    # stripping any timezone suffixes (e.g. +[+05:30]+) before parsing.
    module DateParser
      private

      def parse_date(str)
        return nil if str.nil? || str.empty?

        clean = str.gsub(/\[.*?\]/, '').strip

        case clean.length
        when 8  then Time.strptime(clean, '%Y%m%d')
        when 14 then Time.strptime(clean, '%Y%m%d%H%M%S')
        else         Time.parse(clean)
        end
      rescue ArgumentError
        nil
      end
    end
  end
end
