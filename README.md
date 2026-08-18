A high-performance, **100% database-agnostic**, and secure Redmine plugin that integrates an on-premises AI assistant using **Ollama**. It delivers semantic search, issue context-matching, and summaries without sending a single byte of your data to cloud providers like OpenAI or Anthropic.

---

## 🇧🇷 Resumo do Diferencial Comercial

Este plugin foi desenhado especificamente para empresas corporativas e governamentais que utilizam o Redmine *on-premises* e possuem políticas rígidas de privacidade.

* **Privacidade Total:** Roda 100% offline via rede local conectando-se ao Ollama.
* **Busca Semântica Agnóstica:** Diferente de outras soluções, ele calcula a distância de cosseno em memória RAM via Ruby. Não exige extensões complexas como `pgvector` no banco de dados, sendo totalmente compatível com PostgreSQL, MySQL, MariaDB e SQLite.
* **Compatibilidade Máxima:** Construído usando jQuery/AJAX nativo, garantindo funcionamento estável desde versões legadas do Redmine até as distribuições mais recentes no Marketplace.

---

## ✨ Features

* **AI Semantic Search (Issue Matching):** Automatically analyzes the context of new issues and lists the top 3 most semantically similar historical cases with proximity percentages.
* **On-Premises Security:** Connects to any local Ollama server running models like `llama3.1`, `mistral`, or `nomic-embed-text`.
* **Dynamic Web Settings:** Full administrative dashboard to configure server IPs, LLMs, and embedding models without touching code.
* **Native RBAC Security:** Integrated with Redmine's Role-Based Access Control. Decide exactly which roles (e.g., Managers, Developers) can see the AI panel.
* **Non-Blocking Execution:** Vector generation runs in a background thread, ensuring Zero latency when saving or editing tasks in the browser.

---

## 🛠️ System Requirements

* **Redmine:** v4.x, v5.x, or v6.x
* **Ollama Server:** Running on the same machine or accessible via local network.
* **Ollama Models:** `nomic-embed-text` (Required for semantic search) and an LLM of your choice (e.g., `llama3.1:8b`, `mistral:7b`, or `qwen2.5`).

---

## 📥 Installation

### 1. Clone the Plugin

Navigate to your Redmine plugins directory and clone this repository (ensure the folder name is exactly `redmine_local_ai`):

```bash
cd /path/to/redmine/plugins
git clone https://github.com
```

### 2. Install Dependencies & Migrate

Run the bundler and database migration from the Redmine **root directory**:

```bash
cd /path/to/redmine
bundle install
bundle exec rails db:migrate RAILS_ENV=production
```

### 3. Restart Redmine

Restart your application server to load the plugin into memory:

```bash
# For Docker setups:
docker restart <redmine_container_name>

# For Phusion Passenger / Nginx:
touch tmp/restart.txt
```

---

## 🚀 Ollama Server Configuration

To allow Redmine to reach your Ollama server over your local network, ensure Ollama is listening on all network interfaces (`0.0.0.0`).

1. Edit the Ollama systemd service on your AI server:
   ```bash
   sudo systemctl edit ollama.service
   ```
2. Add the following lines:
   ```ini
   [Service]
   Environment="OLLAMA_HOST=0.0.0.0"
   ```
3. Reload and restart the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart ollama
   ```
4. Download the embedding model:
   ```bash
   ollama run nomic-embed-text
   ollama run llama3.1
   ```

---

## ⚙️ Post-Installation Setup
