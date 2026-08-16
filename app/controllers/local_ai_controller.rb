class LocalAiController < ApplicationController
  before_action :find_issue

  def summarize
    parameters = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "../../../parameters.yaml"))
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
    uri = URI(parameters["parameters"]["ollama_host_url"] + "/api/generate")

    begin
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = {
        model: parameters["parameters"]["generate_model_name"], # ou o modelo que tiver lá
        prompt: "Você é um assistente técnico. Resuma de forma muito curta e direta o status atual e os pontos principais deste histórico de tarefa, use bullet points:\n\n#{text_to_analyze}",
        stream: false
      }.to_json

      res = Net::HTTP.start(uri.hostname, uri.port, read_timeout: 60) do |http|
        http.request(req)
      end

      ai_response = JSON.parse(res.body)['response']

      # Renderiza a resposta em formato JSON para o jQuery do frontend ler
      render json: { summary: ai_response }
    rescue => e
      render json: { summary: "Erro de conexão com o Ollama: #{e.message}" }, status: 500
    end
  end

=begin
  do search based on cosseno vector distance
=end

  def find_issue
    @issue = Issue.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Tarefa não encontrada" }, status: 404
  end

  private def cosine_distance(vec1, vec2)
    return 1.0 if vec1.nil? || vec2.nil? || vec1.size != vec2.size

    dot_product = 0.0
    norm_a = 0.0
    norm_b = 0.0

    vec1.each_with_index do |val1, i|
      val2 = vec2[i]
      dot_product += val1 * val2
      norm_a += val1 ** 2
      norm_b += val2 ** 2
    end

    return 1.0 if norm_a == 0 || norm_b == 0

    # Distância de cosseno é 1 menos a similaridade de cosseno
    similarity = dot_product / (Math.sqrt(norm_a) * Math.sqrt(norm_b))
    1.0 - similarity
  end

  def similar
    @issue = Issue.find(params[:issue_id])

    # 1. Busca o vetor da tarefa atual mapeado pelo modelo serializado
    current_embedding_record = IssueEmbedding.find_by(issue_id: @issue.id)

    if current_embedding_record.nil? || current_embedding_record.embedding_data.nil?
      render html: "<li>Nenhum vetor indexado para esta tarefa ainda.</li>".html_safe
      return
    end

    target_vector = current_embedding_record.embedding_data

    # 2. Carrega todos os outros registros de vetores para comparar (exceto a tarefa atual)
    all_embeddings = IssueEmbedding.where.not(issue_id: @issue.id)

    # 3. Calcula a distância de cada um na memória do Ruby e armazena os resultados
    scored_issues = []
    all_embeddings.each do |record|
      distance = cosine_distance(target_vector, record.embedding_data)
      scored_issues << { issue_id: record.issue_id, score: distance }
    end

    # 4. Ordena pela menor distância (mais similares primeiro) e pega os 3 primeiros
    top_similar = scored_issues.sort_by { |item| item[:score] }.first(3)

    # 5. Renderiza a lista de links HTML de forma limpa para a interface
    if top_similar.any?
      html_result = ""
      top_similar.each do |item|
        similar_issue = Issue.find_by(id: item[:issue_id])
        if similar_issue
          # Mostra o ID, assunto e uma tag discreta com a porcentagem aproximada de proximidade
          similarity_percentage = ((1.0 - item[:score]) * 100).round(1)
          html_result += "<li><a href='/issues/#{similar_issue.id}'>##{similar_issue.id}: #{similar_issue.subject}</a> <small style='color: #169c7e;'>(#{similarity_percentage}%)</small></li>"
        end
      end
      render html: html_result.html_safe
    else
      render html: "<li>Nenhuma tarefa semelhante encontrada no histórico.</li>".html_safe
    end
  end

end
