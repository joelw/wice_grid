# encoding: utf-8
require 'csv'

module Wice
  module Exporters
    class ExporterCsv  #:nodoc:

      #:nodoc:
      attr_reader :tempfile

      def initialize(name, field_separator)  #:nodoc:
        @tempfile = Tempfile.new(name)
        @csv = CSV.new(@tempfile, col_sep: field_separator)
      end

      def << (row)  #:nodoc:
        @csv << row
      end

      def render

      end

    end
  end
end