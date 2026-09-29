# frozen_string_literal: true

namespace :redmine_local_ai do
  desc "Cria tarefas de teste no Redmine para validar o plugin de IA"
  task :create_sample_issues => :environment do
    # 1. Validação de segurança: Busca um projeto e um usuário existentes
    # Altere o identificador 'seu-projeto' para o ID/slug real do seu projeto de teste no Redmine
    project = Project.find_by(identifier: 'app-delivery-teste')
    user = User.find_by(login: 'evandrosalvador') # Busca o usuário administrador padrão

    if project.nil?
      puts "❌ ERRO: Projeto não encontrado. Verifique o 'identifier' informado."
      exit
    end

    if user.nil?
      puts "❌ ERRO: Usuário administrador não encontrado."
      exit
    end

    # 2. Busca o primeiro rastreador (Tracker) disponível no projeto (Ex: Bug, Suporte, Tarefa)
    tracker = project.trackers.first
    if tracker.nil?
      puts "❌ ERRO: O projeto não possui nenhum Rastreador associado."
      exit
    end

    # 3. Define uma lista de tarefas técnicas para testar a IA e os Embeddings posteriormente
    issues_to_create = [
      # --- GRUPO 1: Infraestrutura / Banco de Dados ---
      {
        subject: "Erro crítico de conexão com o banco de dados Postgres",
        description: "O sistema apresentou instabilidade e caiu por volta das 14h após estouro no pool de conexões do PostgreSQL."
      },
      {
        subject: "Timeout intermitente em consultas longas de relatórios",
        description: "A tabela de logs está muito pesada. O servidor de banco trava quando gerentes tentam extrair relatórios anuais."
      },
      {
        subject: "Queda na produção por falta de memória na instância do BD",
        description: "Alerta do monitoramento: Uso de memória RAM atingiu 99% no servidor que roda o banco de dados principal."
      },

      # --- GRUPO 2: Redes / Configuração do Ollama ---
      {
        subject: "Instalação do driver de rede no servidor Ubuntu local",
        description: "Configurar as placas de rede do ambiente local para aceitar pacotes e conexões externas na porta do Ollama."
      },
      {
        subject: "Bloqueio de firewall bloqueando tráfego na porta 11434",
        description: "O Redmine não consegue alcançar o servidor de inteligência artificial porque as regras do iptables barram a porta 11434."
      },
      {
        subject: "Ajustar mapeamento de rede interna entre containers Docker",
        description: "Os serviços de back-end precisam se comunicar via rede interna isolada para evitar exposição de IPs na internet pública."
      },

      # --- GRUPO 3: Autenticação / API / Segurança ---
      {
        subject: "Falha na sincronização de dados do helpdesk via API",
        description: "Chamados externos não estão batendo na rota do controller por falta de token de autenticação CSRF."
      },
      {
        subject: "Token de acesso expirado na integração do webhook externo",
        description: "O serviço de terceiros retornou erro de credenciais inválidas. Precisamos renovar a chave de API na interface."
      },
      {
        subject: "Usuários relatando erro 403 ao tentar anexar arquivos",
        description: "A política de permissões de segurança impede que usuários com papel de 'Visualizador' façam upload de imagens nos comentários."
      },

      # --- GRUPO 4: Frontend / Interface do Usuário ---
      {
        subject: "Botão do assistente de IA sumiu após atualização do tema",
        description: "O CSS do novo tema sobrescreveu os identificadores do nosso plugin, ocultando o botão de resumo da barra lateral."
      },
      {
        subject: "Interface do quadro Kanban quebrando em telas menores",
        description: "Problema de responsividade no frontend. O layout de arrastar e soltar quebra o grid em resoluções mobile."
      }
    ]

    puts "🚀 Iniciando a criação de #{issues_to_create.size} tarefas no projeto: #{project.name}..."

    # 4. Loop para instanciar e salvar as tarefas usando o Active Record do Redmine
    issues_to_create.each_with_index do |data, index|
      issue = Issue.new
      issue.project = project
      issue.tracker = tracker
      issue.author = user
      issue.subject = data[:subject]
      issue.description = data[:description]
      issue.status = IssueStatus.find_by(name: 'New') # Pega o status inicial padrão (ex: Nova)
      issue.priority = IssuePriority.default # Pega a prioridade padrão (ex: Normal)

      if issue.save
        puts "✅ [#{index + 1}] Tarefa ##{issue.id} criada com sucesso: '#{issue.subject}'"
      else
        puts "❌ [#{index + 1}] Falha ao criar a tarefa: #{issue.errors.full_messages.join(', ')}"
      end
    end

    puts "🎉 Processo concluído!"
  end
end
