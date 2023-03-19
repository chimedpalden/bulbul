module Embedding
  class PdfFormatter
    MODEL_NAME = "curie".freeze
    DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001".freeze
    TOKENIZER_CODE = "gpt2".freeze

    def initialize(path)
      @filename = File.basename(path)
      @reader = PDF::Reader.new(path)
    end

    def format
      pdf_pages_csv
      pdf_embedding_csv
    end

    private

    def pdf_pages_csv
      puts "creating pages csv file ....\n ..\n"
      parse_file
      df = Rover::DataFrame.new(@result)
      @df = df[df[:tokens] < 2046]
      File.write(ENV['PAGES_CSV_FILE'], @df.to_csv)
      puts "#{ENV['PAGES_CSV_FILE']} is generated"
    end

    def pdf_embedding_csv
      puts "creating embeddings csv file ....\n ..\n"
      @openai = OpenAI::Client.new(access_token: ENV['OPENAI_TOKEN'])
      @embedding_array = []
      @df.each_row do |row|
        response = get_embedding(row)
        embedding = response['data'][0]['embedding']
        embedding_hash = { title: row[:title], embedding: embedding }
        @embedding_array << embedding_hash
      end
      create_embedding_csv    
    end

    def create_embedding_csv
      CSV.open("#{ENV['EMBEDDED_CSV_FILE']}", "w") do |csv|
        csv << [:title, :embedding]
        @embedding_array.each do |obj|
          csv << [obj[:title], obj[:embedding]]
        end
      end
      puts "#{ENV['EMBEDDED_CSV_FILE']} is generated"
    end

    def get_embedding(row)
      @openai.embeddings(
        parameters: {
          model: DOC_EMBEDDINGS_MODEL,
          input: row[:content]
        }
      )
    end

    def parse_file
      @result = @reader.pages.map.with_index do |page, idx|
        text = page.text.split().join(" ")
        data_format(text, idx)
      end
    end

    def data_format(content, idx)
      {
        title: "Page #{idx}",
        content: content,
        tokens: count_token(content)
      }
    end

    def count_token(content)
      tokenizer = Tokenizers.from_pretrained(TOKENIZER_CODE)
      tokenizer.encode(content).tokens.count
    end
  end
end
