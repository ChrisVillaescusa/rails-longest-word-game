class ControlController < ApplicationController
  def game
    @grid = generate_grid(8)
  end

  def score
    if session[:nb_of_games]
     session[:nb_of_games] += 1
    else
     session[:nb_of_games]=1
    end

    if session[:scores]
      session[:average_score] += session[:average_score]
    else

    end





    @start_time = Time.parse(params[:start_time])
    @attempt = params[:query]
    @grid = params[:grid].split("")
    @end_time = Time.now
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  require 'open-uri'
  require 'json'

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end


  def included?(guess, grid)
    guess.split("").all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: (end_time - start_time).round(2) }
    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "cb7f3261-f193-44af-9ac8-b6ee79a53125"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      raise
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end



end
