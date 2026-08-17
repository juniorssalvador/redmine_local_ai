require_dependency File.expand_path('../lib/hooks', __FILE__)
require 'yaml'

Redmine::Plugin.register :redmine_local_ai do
  name 'Redmine Local Ai plugin'
  author 'Evandro Salvador'
  description 'Local AI into redmine'
  version '0.0.1'
  url 'https://github.com/juniorssalvador/redmine_local_ai'
  author_url 'https://github.com/juniorssalvador/redmine_local_ai'

  project_module :local_ai_assistant do
    # Define a permissão pública ou restrita para a busca semântica
    permission :view_similar_issues, { :local_ai_similar => [:similar] }, :public => false
  end

end

# Preparando o patch para o modelo Issue

Issue.class_eval do
  after_save :generate_ai_embedding

  def generate_ai_embedding

    # load information from file config
    parameters = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/parameters.yaml"))

    # Executa em segundo plano para não travar a interface web do usuário
    Thread.new do

      begin
        content = "Título: #{self.subject}. Descrição: #{self.description}"

        # IP da sua máquina com Ollama (Altere para o IP real da sua rede)
        uri = URI(parameters["parameters"]["ollama_host_url"] + "/api/embeddings")

        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        req.body = { model: parameters["parameters"]["vectoring_model_name"], prompt: content }.to_json

        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end

        embedding_vector = JSON.parse(res.body)['embedding']

        # Lógica agnóstica de salvamento usando o ORM do Rails

        record = IssueEmbedding.find_or_initialize_by(issue_id: self.id)
        record.ia_model_name = parameters["parameters"]["vectoring_model_name"]
        record.embedding_data = embedding_vector # O Rails serializa em JSON automaticamente
        record.save!

      rescue => e
        Rails.logger.error "Erro ao gerar embedding de IA: #{e.message}"
      end
    end
  end
end
