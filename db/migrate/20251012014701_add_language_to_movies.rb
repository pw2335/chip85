class AddLanguageToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :language, :string
  end
end
