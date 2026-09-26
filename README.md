
# 🤖 LangGraph Agentic AI Chatbot

A multi-use-case agentic AI application built with **LangGraph** and **Streamlit**. Supports three modes — a basic chatbot, a web-search-enabled chatbot, and an automated AI news summarizer that fetches, summarizes, and saves the latest AI news as a Markdown report.


## 📋 Overview

This project demonstrates how to build stateful, multi-agent AI workflows using LangGraph. Each use case is a separate compiled graph — the user selects one from the sidebar and the app wires up the correct LLM, tools, and nodes at runtime. No hardcoded pipelines.

🎯 Key Features
🧠 Three Distinct AI Use Cases

Basic Chatbot for general conversation
Web-enabled Chatbot that searches the internet in real time
Automated AI News Summarizer with Daily, Weekly, and Monthly modes

⚡ Agentic Workflow with LangGraph

Each use case is a separate compiled LangGraph graph
Conditional routing — the LLM decides when to call tools and when to answer directly
Loop support — the Chatbot With Web can search multiple times before giving a final answer

🔍 Real-Time Web Search

Tavily API integration for live web results
LLM reasons over search results before responding
AI News pipeline fetches up to 20 latest articles per run

📰 Automated News Summarization

Fetches top AI and tech news from India and globally
LLM summarizes articles into clean Markdown with dates, summaries, and source links
Output saved as a .md file — readable inside and outside the app

🔧 Config-Driven UI

All UI labels, model options, and use case options come from a single .ini file
Adding a new use case or model requires zero changes to Streamlit code

🔑 Bring Your Own API Keys

No keys hardcoded anywhere
Keys entered directly in the sidebar at runtime
.env.example provided for local setup

🐍 Clean Modular Architecture

Nodes, graphs, tools, state, LLMs, and UI are all separate modules
Easy to extend — new use case means a new node file + one line in the config


## 🎯 Use Cases

| Use Case | Description |
|---|---|
| **Basic Chatbot** | Conversational chatbot powered by Groq LLM. Maintains message history within a session. |
| **Chatbot With Web** | Same chatbot extended with Tavily web search. The LLM autonomously decides when to search and reasons over live results. |
| **AI News Summarizer** | Fully automated agentic pipeline. Fetches top AI/tech news via Tavily, summarizes it using the LLM into structured Markdown, and saves a report. Pick Daily, Weekly, or Monthly. |

---

## 🏗️ System Architecture


      User (Browser)
             │
             ▼
┌─────────────────────────────┐
│     Streamlit UI            │
│  Sidebar: LLM, API keys,    │
│  use case, timeframe        │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│     GroqLLM (groqllm.py)    │
│  Initializes ChatGroq with  │
│  selected model + API key   │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│   GraphBuilder              │
│  (graph_builder.py)         │
│  Compiles the right graph   │
│  for the selected use case  │
└────────────┬────────────────┘
             │
      ┌──────┴──────────────────────────┐
      │                                 │
      ▼                                 ▼
┌───────────────────┐     ┌─────────────────────────┐
│  Basic Chatbot    │     │  Chatbot With Web       │
│                   │     │                         │
│  START            │     │  START                  │
│    │              │     │    │                    │
│    ▼              │     │    ▼                    │
│  chatbot          │     │  chatbot ──► tools      │
│    │              │     │    ▲           │        │
│    ▼              │     │    └───────────┘        │
│   END             │     │    │                    │
└───────────────────┘     │    ▼                    │
                          │   END                   │
                          └─────────────────────────┘

┌─────────────────────────────────────────────────────┐──┐
│  AI News Pipeline                                      │
│                                                        │
│START → fetch_news → summarize_news → save_result → END │
└─────────────────────────────────────────────────────┘──┐
                        │
                        ▼
            ┌─────────────────────────────┐
            │  DisplayResultStreamlit     │
            │  Renders output per         │
            │  use case in Streamlit UI   │
            └─────────────────────────────┘


For the full design — state schema, node logic, routing conditions, and UI config system — see [ARCHITECTURE.md](./ARCHITECTURE.md).

---

## 📦 Project Structure

```
AgenticChatbot/
│
├── app.py                          # Entry point — runs the Streamlit app
├── requirements.txt                # Python dependencies
├── .env.example                    # Environment variable template
├── README.md                       # Project overview (this file)
├── ARCHITECTURE.md                 # System design and graph flow
├── CONTRIBUTING.md                 # Contribution guidelines
│
├── AINews/                         # Auto-generated news summary output
│   ├── daily_summary.md
│   └── weekly_summary.md
│
└── src/
    └── langraphAgenticAI/
        │
        ├── main.py                 # Orchestrates UI → LLM → Graph → Display
        │
        ├── graph/
        │   └── graph_builder.py    # Builds LangGraph graph per use case
        │
        ├── nodes/
        │   ├── basic_chatbot_node.py      # Simple LLM call node
        │   ├── chatbot_with_tool_node.py  # LLM + Tavily tool binding node
        │   └── ai_news_node.py            # fetch → summarize → save nodes
        │
        ├── state/
        │   └── state.py            # Shared LangGraph state schema
        │
        ├── tools/
        │   └── search_tool.py      # Tavily search tool + ToolNode factory
        │
        ├── LLMS/
        │   └── groqllm.py          # Groq LLM initialization
        │
        └── ui/
            ├── uiconfigfile.ini    # UI config (titles, options, models)
            ├── uiconfigfile.py     # Config reader using ConfigParser
            └── streamlitui/
                ├── loadui.py           # Sidebar controls and session state
                └── display_result.py   # Renders output per use case

---

## 📚 Technology Stack

| Component | Technology | Purpose |
|---|---|---|
| Agentic Workflow | [LangGraph]| Stateful graph orchestration, node routing, loops |
| LLM Framework | [LangChain] | LLM abstraction, prompts, message types |
| LLM Provider | [Groq — ChatGroq] | Fast LLM inference, free tier available |
| Web Search | [Tavily] | Real-time news and web search API |
| UI | [Streamlit] | Web application interface |
| LangChain Tavily | [langchain-tavily]| LangChain-compatible Tavily tool wrapper |

---

## ✅ Prerequisites

- Python 3.9 or higher
- [Groq API key](https://console.groq.com/keys) — free tier available
- [Tavily API key](https://app.tavily.com/home) — needed for Chatbot With Web and AI News

---

## ⚙️ Setup

1. Clone the repo
2. Create and activate a virtual environment
3. Install dependencies
4. Set up environment variables

## 🚀 Running the Appss

'''terminal
streamlit run app.py
'''
The app opens at http://localhost:8501.

---

## 🖥️ How to Use

**Step 1** — Open the app and expand the sidebar

**Step 2** — Enter your **Groq API key**

**Step 3** — Select a use case:

- **Basic Chatbot** — Type a message in the chat input and press Enter
- **Chatbot With Web** — Enter your Tavily API key, then type your message. The LLM will search when needed.
- **AI News** — Enter your Tavily API key → pick a time frame (Daily / Weekly / Monthly) → click **Fetch Latest AI News**

> For AI News, the generated summary is also saved to `AINews/{timeframe}_summary.md`

For the detailed design — state schema, node logic, routing conditions, and the UI config system — see ARCHITECTURE.md.

---

## 🔑 Environment Variables
# Variable	        # Required For	            # Where to Get
GROQ_API_KEY	    All use cases	            console.groq.com/keys
TAVILY_API_KEY	    Chatbot With Web, AI News	app.tavily.com


## 📈 Project Status

| Feature | Status |
|---|---|
| Basic Chatbot | ✅ Complete |
| Chatbot With Web Search | ✅ Complete |
| AI News Summarizer (Daily/Weekly/Monthly) | ✅ Complete |
| Config-driven UI | ✅ Complete |
| Markdown news report output | ✅ Complete |


## 🗺️ Roadmap

- [ ] Conversation memory across sessions (persistent storage)
- [ ] Support for additional LLM providers (OpenAI, Ollama, Anthropic)
- [ ] Monthly news summary output
- [ ] Unit tests for node logic
- [ ] Docker setup for one-command run
- [ ] User authentication

---


## 🤝 Contributing

Contributions are welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to get started, good first issues, and the commit message format.


## 📚 Technology Stack

| Component | Technology | Version |
|---|---|---|
| Workflow Orchestration | LangGraph | 1.2.4 |
| LLM Framework | LangChain | 1.3.7 |
| LLM Core | LangChain Core | 1.4.0 |
| Community Integrations | LangChain Community | 0.4.2 |
| LLM Provider (Groq) | LangChain Groq | 1.1.3 |
| LLM Provider (OpenAI) | LangChain OpenAI | 1.2.2 |
| Web Search Client | Tavily Python | 0.7.27 |
| LangChain Search Tool | LangChain Tavily | Latest |
| Vector Store | FAISS CPU | 1.15.0 |
| UI Framework | Streamlit | 1.51.0 |


## 🙏 Acknowledgments

- [LangGraph] — for making stateful agentic workflows approachable
- [LangChain] — for the LLM abstraction layer
- [Groq] — for fast and free LLM inference
- [Tavily] — for the real-time search and news API
- [Streamlit]— for the rapid UI framework

---

## 👤 Author

**Shivam Singh**

- GitHub: @ssinghdev1
- Project: Agentic AI Project

---

## 💬 Support

- Found a bug? [Open an issue](https://github.com/ssinghdev1/AgenticChatbot/issues)
- Have a question? Tag it with `question` when opening an issue
- Want to contribute? See [CONTRIBUTING.md](./CONTRIBUTING.md)

---

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

---

*Last Updated: September 2026 — Status: ✅ Active*

