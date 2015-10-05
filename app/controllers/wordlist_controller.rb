require "lemmatizer"

FREQUENCY_BREAK_POINT = 1800
class WordlistController < ApplicationController
  def index
  end

  def get_wordlist
    words = JSON.parse(request.body.read)

    lemmatizer = Lemmatizer.new
    words = words.map { |x| x.downcase }
    corpuses = Corpus.where(word: words)

    wordAndFrequency = {}
    corpuses.each do |corpus|
      unless wordAndFrequency[corpus.word].nil?
        wordAndFrequency[corpus.word] += corpus.frequency
      else
        wordAndFrequency[corpus.word] = corpus.frequency
      end
    end

    wordlist = {}
    wordAndFrequency.to_a
      .select { |word, frequency| frequency < FREQUENCY_BREAK_POINT }
      .map { |word, frequency| word }
      .map do |word|
        dict_item = Word.find_by(word: lemmatizer.lemma(word))
        hash = Hash.new
        unless dict_item.nil?
          definition = dict_item.definition
          short_definition = definition.split(%r{[:,\s]}).first
          short_definition = short_definition.split('.')
          if short_definition.size == 2
            short_definition = short_definition.second
          else
            short_definition = short_definition.first
          end
          wordlist[word] = {
            short_definition: short_definition,
            definition: definition
          }
        end
      end

    respond_to do |format|
      format.json { render json: wordlist }
    end
  end
end
