class CreateCorpus < ActiveRecord::Migration
  def change
    create_table :corpus do |t|
      t.string :word
      t.integer :frequency
      t.string :pos
      t.integer :occured_number_in_file

      t.timestamps
    end
  end
end
