# ./lib/tasks/pdf_to_page_embeddings.rake

require 'embedding/pdf_formatter'

namespace :embedding do
  desc "Format PDF manuscript as local data file with embeddings."
  task :pdf, [:path] do |t, args|
    unless Pathname.new(args[:path]).exist?
      puts "File doesn't exit. Pls re-check the file path #{path}"
      return
    end
    puts "formatting the PDF manuscript as local data file with embeddings."
    Embedding::PdfFormatter.new(args[:path]).format
  end
end
