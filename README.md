
## Agentic AI Chatbot

A multi-use-case agentic AI application built with LangGraph and Streamlit. 
It supports three modes: a basic chatbot, a web-search-enabled chatbot, and an AI news summarizer that fetches, summarizes, and saves the latest AI news.

Basic Chatbot : Conversational chatbot powered by Groq LLM. No external tools.

Chatbot With Web : Same chatbot but with Tavily web search integrated. The LLM decides when to search and reasons over live results before responding.

AI News Summarizer: An agentic pipeline that fetches top AI/tech news via Tavily, summarizes it using the LLM into structured Markdown, and saves it as a file. You pick Daily, Weekly, or Monthly, the agent handles the rest.

## What it does

Basic Chatbot : Conversational chatbot powered by Groq LLM. No external tools.
Chatbot With Web : Same chatbot with Tavily web search. The LLM decides when to search and reasons over live results.
AI News Summarizer: Agentic pipeline that fetches top AI/tech news via Tavily, summarizes it with the LLM, and saves a Markdown report. Pick Daily, Weekly, or Monthly.

## Tech Stack

[LangGraph] - Stateful graph / agentic workflow orchestration
[LangChain] - LLM abstraction, prompts, message types
[Groq — ChatGroq] - LLM inference backend
[Tavily] - Real-time web search API
[Streamlit] - Web UI 


## Project Structure
AgenticChatbot/ 
├── app.py # Entry point - runs the Streamlit app 
├── requirements.txt # Python dependencies
├── .env.example # Environment variable template
├── ARCHITECTURE.md # System design and graph flow
├── CONTRIBUTING.md # Contribution guidelines
├── AINews/ # Auto-generated news summary output - daily_summary.md - weekly_summary.md

└── src/langraphAgenticAI/ 
├── main.py # Orchestrates UI → LLM → Graph → Display 
├── graph/ - graph_builder.py # Builds LangGraph graph per use case
├── nodes/ - basic_chatbot_node.py # Simple LLM call node │ chatbot_with_tool_node.py # LLM + tool binding node │ ai_news_node.py # fetch → summarize → save pipeline nodes 
├── state/ │ state.py # Shared LangGraph state schema
├── tools/ │ └── search_tool.py # Tavily search tool + ToolNode factory
├── LLMS/  │ └── groqllm.py # Groq LLM initialization
└── ui/ ├── uiconfigfile.ini # UI config (titles, options, models) ├── uiconfigfile.py # Config reader using ConfigParser └── streamlitui/ ├── loadui.py # Sidebar controls and session state └── display_result.py # Renders output per use case


## Prerequisites

- Python 3.9 or higher
- A [Groq API key](https://console.groq.com/keys)
- A [Tavily API key](https://app.tavily.com/home) (needed for Chatbot With Web and AI News)

## Setup
1. Clone the repo
2. Create and activate a virtual environment
3. Install dependencies
4. Set up environment variables

## Running the App

streamlit run app.py
The app opens at http://localhost:8501.

## How to Use
Step 1 - Open the sidebar
Step 2 - Enter your Groq API key
Step 3 - Select a use case:

Basic Chatbot -- Type a message in the chat box and press Enter
Chatbot With Web -- Enter your Tavily API key, then type your message
AI News-- Enter your Tavily API key, pick a time frame (Daily / Weekly / Monthly), and click Fetch Latest AI News

For AI News, the generated summary is also saved to AINews/{timeframe}_summary.md so you can refer to it anytime.


## How it Works
The app is built around three separate LangGraph graphs — one per use case. Each graph is compiled at runtime based on what the user selects.

1. Basic Chatbot graph: START → chatbot → END

2. Chatbot With Web graph: 
START → chatbot ──(has tool calls?)──► tools → chatbot → ...
                └───────────────────► END

3. AI News pipeline graph: START → fetch_news → summarize_news → save_result → END

For the detailed design — state schema, node logic, routing conditions, and the UI config system — see 
ARCHITECTURE.md.

## Environment Variables
# Variable	        # Required For	            # Where to Get
GROQ_API_KEY	    All use cases	            console.groq.com/keys
TAVILY_API_KEY	    Chatbot With Web, AI News	app.tavily.com

## Contributing
Contributions are welcome. See CONTRIBUTING.md for how to get started, what makes a good first issue, and the commit message format.

