require_relative '../helpers/setup_ssl'

class LocalAiSummarizeController < ApplicationController
  before_action :find_issue

  def summarize

    plugin_settings = Setting.plugin_redmine_local_ai || {}
    ollama_url = plugin_settings['ollama_url'].presence || 'http://127.0.0.1:11434'
    llm_model = plugin_settings['llm_model'].presence || 'nomic-embed-text'

    # 1. Coleta a descrição da tarefa
    text_to_analyze = "Descrição: #{@issue.description}\n"

    # 2. Coleta todos os comentários (Journals) técnicos da tarefa
    @issue.journals.each do |journal|
      if journal.notes.present?
        text_to_analyze += "Comentário: #{journal.notes}\n"
      end

    end

    # 3. Faz a requisição HTTP para a máquina do Ollama na sua rede local
    # Altere o IP abaixo para o IP real da sua máquina com Ollama
    uri = URI(ollama_url + "/api/generate")
    net_http_start = SetupSSL.new.setup_http(uri)

    begin
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = {
        model: llm_model, # ou o modelo que tiver lá
        prompt: "Você é um assistente técnico. Resuma de forma muito curta e direta o status atual e os pontos principais deste histórico de tarefa, use bullet points:\n\n#{text_to_analyze}",
        stream: false
      }.to_json

      res = net_http_start.request(req)
      ai_response = JSON.parse(res.body)['response']

      # Renderiza a resposta em formato JSON para o jQuery do frontend ler
      render json: { summary: ai_response }
    rescue => e
      render json: { summary: "Erro de conexão com o Ollama: #{e.message}" }, status: 500
    end
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Tarefa não encontrada" }, status: 404
  end

end
