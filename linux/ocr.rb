#!/usr/bin/env ruby

(ARGV.length>0) || puts("usage: ./ocr.rb file1.pdf  ...") || exit(0)
$basedir=Dir.getwd
ARGV.grep(/\.pdf/i).each do |pdf|
      dir = pdf.gsub(/\.pdf/,'')
#      dir += '_OCR'
      dir += '.dir' if(dir == pdf)
      Dir.mkdir(dir) unless(File.exist?(dir))
      Dir.chdir(dir)
      puts "Extracting pages from PDF: #{pdf}"
      system "gs -r300x300 -sDEVICE=tiffgray -sOutputFile=ocr_%02d.tif -dBATCH -dNOPAUSE \"#{$basedir}/#{pdf}\""
      tiff_pages = Dir.new('.').grep(/^ocr.*\.tif$/).sort
      puts "Running tesseract OCR on pages: #{tiff_pages.join(', ')}"
      tiff_pages.each do |page|
              page_base = page.gsub(/\.tif.*/,'')
              print "#{page_base} "
              system "/usr/bin/tesseract #{page} #{page_base}"
      end
      Dir.chdir($basedir)
      ocr_pages = Dir.new(dir).grep(/^ocr.*\.txt$/).sort
      if ocr_pages && ocr_pages.length>0
              puts "Created OCR result pages: #{ocr_pages.join(', ')}"
#              archive = "#{dir}.zip"
#              puts "Creating archive of result pages: #{archive}"
#              system "zip -r \"#{archive}\" #{ocr_pages.map{|p| "\"#{dir}/#{p}\""}.join(' ')}"
      else
              puts "No OCR result pages found"
      end
      puts ""
end
