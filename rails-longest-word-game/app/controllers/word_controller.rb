class WordController < ApplicationController

  def game
    @grid = Array.new(9) { ('A'..'Z').to_a[rand(26)] }
    @grid_string = @grid.join
  end

  def score
    @grid_string = params[:grid]
    @guess = params[:solution]
    @time_taken = Time.now - Time.parse(params[:start_time])

    @include = includes?(@guess, @grid_string)

    @translation = api_call(@guess)

    @score = compute_score(@guess, @time_taken)
  end

  private

  def includes?(word, grid)
    return @guess.upcase.split('').all? { |letter| @guess.count(letter) <= @grid_string.count(letter) }
  end

  def api_call(word)
        api_key = "5d7950f4-bbbd-455c-81e3-60ce01c469cd"
      begin
        response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
        json = JSON.parse(response.read.to_s)
        if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
          return json['outputs'][0]['output']
        end
      end
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end
end
