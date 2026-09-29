# Redmine Local AI Plugin

A secure, database-agnostic Redmine plugin that integrates an on-premises AI assistant using Ollama for semantic search and summaries.

---

## 🛠️ System Requirements

* **Redmine:** v4.x, v5.x, or v6.x
* **Ollama Server:** Running on the same machine or accessible via local network.
* **Ollama Models:** `nomic-embed-text` (Required) and an LLM (e.g., `llama3.1:8b`, `mistral:7b`, or `qwen2.5`).

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
Restart your application server to load the plugin:
```bash
# For Docker setups:
docker restart <redmine_container_name>

# For Phusion Passenger / Nginx:
touch tmp/restart.txt
```

---

## 🚀 Ollama Server Configuration

To allow Redmine to reach your Ollama server over your local network, configure it to listen on `0.0.0.0`.

1. Edit the Ollama systemd service:
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
4. Download the required models:
   ```bash
   ollama run nomic-embed-text
   ollama run llama3.1
   ```

---

## ⚙️ Post-Installation Setup

1. Log in to Redmine as an Administrator.
2. Go to **Administration > Plugins** and configure the `Redmine Local AI` settings.
3. Define your Ollama Server IP, embedding models, and configure the Role-Based Access Control (RBAC) permissions.
