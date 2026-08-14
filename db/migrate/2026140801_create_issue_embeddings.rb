class CreateIssueEmbeddings < ActiveRecord::Migration[6.1]
  def change
    create_table :issue_embeddings do |t|
      t.references :issue, null: false, foreign_key: { on_delete: :cascade }
      t.string :model_name, null: false
      t.text :embedding_data, null: false # Guardará o array convertido em texto/JSON
      t.timestamps
    end

    # Índice único para acelerar a busca e evitar duplicidade
    add_index :issue_embeddings, :issue_id, unique: true
  end
end
