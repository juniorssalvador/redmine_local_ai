class LocalAiSimilarController < ApplicationController
  before_action :find_issue
  before_action :find_project
  before_action :authorize

=begin
  do search based on cosseno vector distance
=end

  def find_issue
    @issue = Issue.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Tarefa não encontrada" }, status: 404
  end

  def find_project
    # O método :authorize do Redmine exige que a variável @project esteja definida
    @project = @issue.project
  end

  def cosine_distance(vec1, vec2)
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
