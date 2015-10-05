# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
def create_dictionary_info
  dict_file = File.expand_path('../fixtures/dict.json', __FILE__)
  parsed_dict = JSON.parse(File.read(dict_file))
  r_remove_pronounce = /^\[.*\]\s+\n\s/

  Word.delete_all

  Word.create(
    parsed_dict.map do |word, definition|
      { word: word, definition: definition.gsub(r_remove_pronounce, '') }
    end
  )
end

create_dictionary_info()
