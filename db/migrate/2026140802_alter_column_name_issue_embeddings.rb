class AlterColumnNameIssueEmbeddings <  ActiveRecord::Migration[6.1]

  def change
    rename_column :issue_embeddings, :model_name, :ia_model_name
  end
end
