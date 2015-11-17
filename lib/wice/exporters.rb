# encoding: utf-8
module Wice #:nodoc:
  module Exporters #:nodoc:
    mattr_reader :handled_exporter
    require 'active_support'

    EXPORTER_INDEX = ActiveSupport::OrderedHash[ #:nodoc:
      :csv,                    'exporter_csv',
      :xls,                    'exporter_excel'
    ]

    class << self

      def load_export_processors #:nodoc:
        require_exporters

        @@handled_exporter = build_table_of_exporters
        
        if Wice::Defaults.const_defined?(:ADDITIONAL_EXPORT_PROCESSORS)

          common_error_prefix = 'Error loading Wice::Defaults::ADDITIONAL_EXPORT_PROCESSORS. '

          Wice::Defaults::ADDITIONAL_EXPORT_PROCESSORS.each do |key, value|
            unless key.is_a?(Symbol)
              fail common_error_prefix + 'A key of Wice::Defaults::ADDITIONAL_EXPORT_PROCESSORS should be a Symbol!'
            end

            if @@handled_exporter.key?(key)
              fail common_error_prefix +
                "Exporter with key \"#{key}\" already exists in WiceGrid, overwriting existing exporters is forbidden, please choose another key!"
            end

            if !value.is_a?(String)
              fail common_error_prefix +
                'A value of Wice::Defaults::ADDITIONAL_EXPORT_PROCESSORS should be a String!'
            end

            export_processor = begin
              eval(value)
            rescue NameError
              raise common_error_prefix + "Class #{value} is not defined!"
            end

            unless export_processor.ancestors.include?(::Wice::Exporters)
              fail common_error_prefix +
                "#{export_processor} should be inherited from Wice::Exporters!"
            end

            @@handled_exporter[key] = export_processor
          end
        end
      end

      def get_export_processor(export_type) #:nodoc:
        @@handled_exporter[export_type] || @@handled_exporter.first # TODO - define fallback here?
      end


      private

      def build_table_of_exporters
        {}.tap do |exporter_table|
          loaded_exporters = {}

          Wice::Exporters::EXPORTER_INDEX.each do |exporter_type, exporter_source_file|
            unless loaded_exporters[exporter_source_file]
              exporter_class_name = "#{exporter_source_file}".classify

              unless Wice::Exporters.const_defined?(exporter_class_name.intern)
                fail "#{exporter_source_file}.rb is expected to define #{exporter_class_name}!"
              end
              exporter_class = eval("Wice::Exporters::#{exporter_class_name}")

              loaded_exporters[exporter_source_file] = exporter_class
            end

            exporter_table[exporter_type] = loaded_exporters[exporter_source_file]
          end
        end
      end

      def require_exporters
        Wice::Exporters::EXPORTER_INDEX.values.uniq do |exporter_source_file|
          require "wice/exporters/#{exporter_source_file}.rb"
        end
      end

    end

  end
end
