module Docsplit

  # Delegates to **pdftk** in order to create bursted single pages from
  # a PDF document.
  class PageExtractor

    # Burst a list of pdfs into single pages, as `pdfname_pagenumber.pdf`.
    def extract(pdfs, opts)
      extract_options opts
      [pdfs].flatten.each do |pdf|
        pdf_name = File.basename(pdf, File.extname(pdf))
        
        if opts[:chunk].nil?
          page_path = ESCAPE[File.join(@output, "#{pdf_name}")] + "_%d.pdf"
        else
          page_text = opts[:pages].first.to_s+'-'+opts[:pages].last.to_s
          page_path = ESCAPE[File.join(@output, "#{pdf_name}")] + "_#{page_text}.pdf"
        end

        FileUtils.mkdir_p @output unless File.exists?(@output)
        
        cmd = if DEPENDENCIES[:pdftailor] # prefer pdftailor, but keep pdftk for backwards compatability
          "pdftailor unstitch --output #{page_path} #{ESCAPE[pdf]} 2>&1"
        else
          opts[:chunk] ? "pdftk A=#{ESCAPE[pdf]} cat A#{page_text} output #{page_path}" : "pdftk #{ESCAPE[pdf]} burst output #{page_path} 2>&1"
        end
        result = `#{cmd}`.chomp
        FileUtils.rm('doc_data.txt') if File.exists?('doc_data.txt')
        raise ExtractionFailed, result if $? != 0
        result
      end
    end


    private

    def extract_options(options)
      @output = options[:output] || '.'
    end

  end

end
