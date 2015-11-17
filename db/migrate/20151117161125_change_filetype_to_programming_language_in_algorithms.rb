class ChangeFiletypeToProgrammingLanguageInAlgorithms < ActiveRecord::Migration
    def change
        rename_column :algorithms, :filetype, :programming_language
  end
end
