require_dependency File.expand_path('../lib/hooks', __FILE__)
require 'yaml'
require_relative 'app/helpers/setup_ssl'

Redmine::Plugin.register :redmine_local_ai do
  name 'Redmine Local Ai plugin'
  author 'Evandro Salvador'
  description 'Local AI into redmine'
  version '0.0.1'
  url 'https://github.com/juniorssalvador/redmine_local_ai'
  author_url 'https://github.com/juniorssalvador/redmine_local_ai'

  settings default: {
    'ollama_url' => 'http://ollama.home.lab',
    'llm_model' => 'llama3.1',
    'embedding_model' => 'nomic-embed-text'
  }, partial: 'settings/local_ai_settings'

  project_module :local_ai_assistant do
    # Define a permissão pública ou restrita para a busca semântica
    permission :view_similar_issues, { :local_ai_similar => [:similar] }, :public => false
  end

end

# Preparando o patch para o modelo Issue
Issue.class_eval do
  after_save :generate_ai_embedding

  def generate_ai_embedding

=begin
    load settings from database
=end

    plugin_settings = Setting.plugin_redmine_local_ai || {}
    ollama_url = plugin_settings['ollama_url'].presence || 'http://127.0.0.1:11434'
    embed_model = plugin_settings['embedding_model'].presence || 'nomic-embed-text'

    # Executa em segundo plano para não travar a interface web do usuário
    Thread.new do

      begin

        content = "Título: #{self.subject}. Descrição: #{self.description}"
        uri = URI(ollama_url + "/api/embeddings")

        net_http_start = SetupSSL.new.setup_http(uri)

        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        req.body = { model: embed_model, prompt: content }.to_json

        res = net_http_start.request(req)
        p res.body

        embedding_vector = JSON.parse(res.body)['embedding']

        # Lógica agnóstica de salvamento usando o ORM do Rails

        record = IssueEmbedding.find_or_initialize_by(issue_id: self.id)
        record.ia_model_name = embed_model
        record.embedding_data = embedding_vector # O Rails serializa em JSON automaticamente

        record.save!

      rescue => e
        Rails.logger.error "Erro ao gerar embedding de IA: #{e.message}"
      end
    end
  end
end
