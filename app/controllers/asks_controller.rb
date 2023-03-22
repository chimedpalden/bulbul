class AsksController < ApplicationController
  before_action :set_ask, only: %i[ show ]
  before_action :check_cache, only: [:create]

  # GET /asks or /asks.json
  def index
    @asks = Ask.all
    render
  end

  # GET /asks/1 or /asks/1.json
  def show
  end

  # GET /asks/1/edit
  def edit
  end

  # POST /asks or /asks.json
  def create
    if check_cache
      render json: { answer: @answer, question: params[:ask][:question] }
    elsif fetch_question
      render json: @ask
    else
      ask = Ask.new(ask_params)
      if ask.save
        ask.get_answer
        render json: ask, status: :created
      else
        render json: ask.errors, status: :unprocessable_entity
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ask
      @ask = Ask.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ask_params
      params.require(:ask).permit(:question, :answer)
    end

    def fetch_question
      @ask = Ask.find_by(question: params[:ask][:question])
      @ask&.answer
    end

    def check_cache
      @answer = RedisService.instance.get(params[:ask][:question])
    end
end
