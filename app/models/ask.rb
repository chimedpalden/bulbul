class Ask < ApplicationRecord
  MODEL_NAME = "curie".freeze
  QUERY_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-query-001".freeze
  COMPLETIONS_MODEL = "text-davinci-003".freeze
  MAX_SECTION_LEN = 500
  SEPARATOR = "\n* "
  SEPARATOR_LEN = 3

  validates :question, presence: true, length: { maximum: 140 }
  validates :answer, length: { maximum: 1000 }, allow_blank: true
  before_create :format_question

  def get_answer
    @openai = OpenAI::Client.new(access_token: ENV['OPENAI_TOKEN'])
    @document_embeddings = load_doc_embeddings
    @query_embedding = get_query_embedding
    @document_content = SmarterCSV.process(ENV['PAGES_CSV_FILE'])
    answer = answer_query_with_context
    self.update(answer: answer, context: @context)
  end

  def answer_query_with_context
    construct_prompt
    puts "====\n#{@prompt}"

    response = @openai.completions(
      parameters: {
        model: COMPLETIONS_MODEL,
        prompt: @prompt,
        temperature: 0.0,
        max_tokens: 500,
      }
    )
    response["choices"][0]["text"].lstrip
  end

  def construct_prompt
    most_relevant_document_sections = order_document_sections_by_query_similarity

    @chosen_sections = []
    chosen_sections_len = 0
    chosen_sections_indexes = []

    most_relevant_document_sections.each do |x|
      section_index = x[1].to_s
      document_section = @document_content.find { |page| page[:title] == section_index }

      chosen_sections_len += document_section[:tokens] + SEPARATOR_LEN
      if chosen_sections_len > MAX_SECTION_LEN
        space_left = MAX_SECTION_LEN - chosen_sections_len - SEPARATOR_LEN
        @chosen_sections.push(SEPARATOR + document_section[:content][0...space_left])
        chosen_sections_indexes.push(section_index)
        break
      end

      @chosen_sections.push(SEPARATOR + document_section[:content])
      chosen_sections_indexes.push(section_index)
    end
    set_prompt
  end

  def set_prompt
    header = """Sahil Lavingia is the founder and CEO of Gumroad, and the author of the book The Minimalist Entrepreneur (also known as TME). These are questions and answers by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\nContext that may be useful, pulled from The Minimalist Entrepreneur:\n"""

    question_1 = "\n\n\nQ: How to choose what business to start?\n\nA: First off don't be in a rush. Look around you, see what problems you or other people are facing, and solve one of these problems if you see some overlap with your passions or skills. Or, even if you don't see an overlap, imagine how you would solve that problem anyway. Start super, super small."
    question_2 = "\n\n\nQ: Q: Should we start the business on the side first or should we put full effort right from the start?\n\nA:   Always on the side. Things start small and get bigger from there, and I don't know if I would ever “fully” commit to something unless I had some semblance of customer traction. Like with this product I'm working on now!"
    question_3 = "\n\n\nQ: Should we sell first than build or the other way around?\n\nA: I would recommend building first. Building will teach you a lot, and too many people use “sales” as an excuse to never learn essential skills like building. You can't sell a house you can't build!"
    question_4 = "\n\n\nQ: Andrew Chen has a book on this so maybe touché, but how should founders think about the cold start problem? Businesses are hard to start, and even harder to sustain but the latter is somewhat defined and structured, whereas the former is the vast unknown. Not sure if it's worthy, but this is something I have personally struggled with\n\nA: Hey, this is about my book, not his! I would solve the problem from a single player perspective first. For example, Gumroad is useful to a creator looking to sell something even if no one is currently using the platform. Usage helps, but it's not necessary."
    question_5 = "\n\n\nQ: What is one business that you think is ripe for a minimalist Entrepreneur innovation that isn't currently being pursued by your community?\n\nA: I would move to a place outside of a big city and watch how broken, slow, and non-automated most things are. And of course the big categories like housing, transportation, toys, healthcare, supply chain, food, and more, are constantly being upturned. Go to an industry conference and it's all they talk about! Any industry…"
    question_6 = "\n\n\nQ: How can you tell if your pricing is right? If you are leaving money on the table\n\nA: I would work backwards from the kind of success you want, how many customers you think you can reasonably get to within a few years, and then reverse engineer how much it should be priced to make that work."
    question_7 = "\n\n\nQ: Why is the name of your book 'the minimalist entrepreneur' \n\nA: I think more people should start businesses, and was hoping that making it feel more “minimal” would make it feel more achievable and lead more people to starting-the hardest step."
    question_8 = "\n\n\nQ: How long it takes to write TME\n\nA: About 500 hours over the course of a year or two, including book proposal and outline."
    question_9 = "\n\n\nQ: What is the best way to distribute surveys to test my product idea\n\nA: I use Google Forms and my email list / Twitter account. Works great and is 100% free."
    question_10 = "\n\n\nQ: How do you know, when to quit\n\nA: When I'm bored, no longer learning, not earning enough, getting physically unhealthy, etc… loads of reasons. I think the default should be to “quit” and work on something new. Few things are worth holding your attention for a long period of time."

    @prompt = header + @chosen_sections.join("") + question_1 + question_2 + question_3 + question_4 + question_5 + question_6 + question_7 + question_8 + question_9 + question_10 + "\n\n\nQ: " + question + "\n\nA: "
    @context = @chosen_sections.join("")
  end

  def order_document_sections_by_query_similarity
    # [(0.33810071861515545, 'Page 1'), (0.23658860232473594, 'Page 2')]
    v2 = @query_embedding
    result = []
    @document_embeddings.each do |title, v1|
      v1 = JSON.parse(v1)
      v3 = Cosine.new(v1, v2).vector_similarity
      result << [v3, title]
    end
    result.sort_by{ |x| -x[0] }
  end

  def get_query_embedding
    response = @openai.embeddings(
      parameters: {
        model: QUERY_EMBEDDINGS_MODEL,
        input: question
      }
    )
    response['data'][0]['embedding']
  end

  def load_doc_embeddings
    embed = SmarterCSV.process(ENV['EMBEDDED_CSV_FILE'])
    embed_hash = {}
    embed.each do |h|
      embed_hash.merge!({ "#{h[:title]}": h[:embedding] })
    end
    embed_hash
  end

  private

  def format_question
    self.question = self.question.strip
    self.question += "?" unless self.question.end_with?("?")
  end
end
