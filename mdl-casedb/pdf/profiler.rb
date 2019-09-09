module Pdf
  class Profiler
    attr_reader :pdf_path
    def initialize(pdf_path)
      @pdf_path = pdf_path
    end

    def self.run(pdf_path)
      self.new(pdf_path).profile
    end

    def profile()
      if (not File.exist?(pdf_path))
        Rails.logger.error("PDF not found #{pdf_path}")
        return
      end

      file_name = File.basename(pdf_path, '.*')
      result_file = "/Users/bchiasson/Desktop/count_profiles/#{file_name}.csv"
      CSV.open(result_file, 'w+b') do |csv|
        csv << ['iteration', 'page_count', 'total_time', 'elapsed_time', 'system_cpu_time', 'user_cpu_time']
        50.times do |i|
          page_count = nil
          tms = Benchmark.measure do
            self.service.get_info(pdf_path) { |info| page_count = info['Pages'] }
          end
          csv << [i, page_count, tms.total, tms.real, tms.stime, tms.utime]
        end
      end
      return
    end

    def service
      @service ||= ::Pdf::DocumentInfoService.new
    end
  end
end
