module Docsplit

  # Delegates to **pdftk** in order to create bursted single pages from
  # a PDF document.
  class PageExtractor

    # Burst a list of pdfs into single pages, as `pdfname_pagenumber.pdf`.
    def extract(pdfs, opts)
      extract_options opts
      [pdfs].flatten.each do |pdf|
        pdf_name = File.basename(pdf, File.extname(pdf))
        page_path = ESCAPE[File.join(@output, "#{pdf_name}")] + "_%d.pdf"
        FileUtils.mkdir_p @output unless File.exists?(@output)
        
        cmd = if DEPENDENCIES[:pdftailor] # prefer pdftailor, but keep pdftk for backwards compatability
          "pdftailor unstitch --output #{page_path} #{ESCAPE[pdf]} 2>&1"
        else
          if opts[:chunk] && opts[:pages]
            page_text = opts[:chunk].first.to_s+'-'opts[:chunk].last.to_s
            "pdftk A=#{ESCAPE[pdf]} cat A#{page_text} output #{page_path}"
          else
            "pdftk #{ESCAPE[pdf]} burst output #{page_path} 2>&1"
          end
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
