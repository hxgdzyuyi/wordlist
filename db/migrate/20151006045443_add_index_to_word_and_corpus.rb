class AddIndexToWordAndCorpus < ActiveRecord::Migration
  def change
    add_index :words, :word
    add_index :corpus, :word
  end
end
