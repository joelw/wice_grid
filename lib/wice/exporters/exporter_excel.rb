# encoding: utf-8

module Wice
  module Exporters
    class ExporterExcel  #:nodoc:

      #:nodoc:
      attr_reader :tempfile

      def initialize(name, field_separator)  #:nodoc:
        @tempfile = Tempfile.new(name)
        @rows = []
      end

      def << (row)  #:nodoc:
        @rows << row
      end

      def render
        header =<<EOF
<?xml version="1.0"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:x="urn:schemas-microsoft-com:office:excel"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:html="http://www.w3.org/TR/REC-html40">
  <Worksheet ss:Name="Sheet1">
    <Table>
EOF

        @tempfile.write header
        @rows.each do |row|
          @tempfile.write "      <Row>\n"
          row.each do |col|
            @tempfile.write %Q(        <Cell><Data ss:Type="String">#{col}</Data></Cell>\n)
          end
          @tempfile.write "      </Row>\n"
        end

        @tempfile.write "    </Table>\n  </Worksheet>\n</Workbook>\n"
        @tempfile.close
      end
    end
  end
end