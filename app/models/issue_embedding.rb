class IssueEmbedding < ActiveRecord::Base
  belongs_to :issue

  # Converte automaticamente o TEXT/JSON do banco em um Array Ruby (e vice-versa)
  serialize :embedding_data, type: Array, coder: JSON


end
