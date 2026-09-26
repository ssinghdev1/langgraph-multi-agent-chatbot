# Architecture

This document explains how the application is structured, how data flows through it end-to-end, and how each LangGraph graph is designed.

---

## End-to-End Application Flow
User (Browser) │ ▼ Streamlit UI ── app.py calls main.py │ │ loadui.py renders sidebar: │ API keys, LLM selection, use case, timeframe ▼ GroqLLM (groqllm.py) │ │ Initializes ChatGroq with selected model + API key ▼ GraphBuilder (graph_builder.py) │ │ Picks the right graph-building method based on use case │ Compiles and returns a LangGraph runnable ▼ Graph Execution │ │ Streams or invokes the compiled graph with user message ▼ DisplayResultStreamlit (display_result.py) │ │ Routes output rendering by use case ▼ User sees response in chat UI

## Shared State

All three graphs use the same `State` TypedDict from `state/state.py`:

```python 
class State(TypedDict):
    messages: Annotated[List, add_messages]
add_messages is a LangGraph reducer — it appends new messages to the list instead of replacing them. This is what gives the chatbot conversational memory within a single session.

Graph 1 — Basic Chatbot File: basic_chatbot_node.py, graph_builder.py

START → chatbot → END

chatbot node (BasicChatbotNode.process): Calls llm.invoke(state['messages']) and returns the AI response. The add_messages reducer accumulates the full conversation history automatically.

When to use: Quick Q&A, no need for live data or external tools.



Graph 2 — Chatbot With Web File: chatbot_with_tool_node.py, search_tool.py, graph_builder.py

START → chatbot ──(has tool calls?)──► tools → chatbot → ...
                └───────────────────► END

chatbot node (ChatbotWithToolNode.create_chatbot): The LLM is bound to a Tavily search tool via .bind_tools(tools). If it decides it needs to search, it emits a tool call message instead of a direct answer.

tools node (ToolNode from langgraph.prebuilt): Executes the Tavily search and returns a ToolMessage with the result.

Routing — tools_condition (built-in LangGraph): Checks the last message. If it contains tool calls → routes to tools. Otherwise → routes to END.

The loop tools → chatbot allows the LLM to reason over the search result and either answer or search again.

Tools defined in search_tool.py:

python

def get_tools():
    return [TavilySearch(max_result=2)]

def create_tool_node(tools):
    return ToolNode(tools=tools)


Graph 3 — AI News Pipeline File: ai_news_node.py, graph_builder.py
START → fetch_news → summarize_news → save_result → END

This is a fully automated agentic pipeline. The user only picks the time frame — the graph does the rest.
fetch_news node (AINewsNode.fetch_news):

Reads frequency (daily / weekly / monthly) from the first message
Maps it to Tavily time range (d / w / m) and days (1 / 7 / 30)
Calls Tavily with:
Query: "Top Artificial Intelligence (AI) technology news India and globally"
Topic: news
Max results: 20
include_answer: "advanced"
Stores raw results in state['news_data']
summarize_news node (AINewsNode.summarize_news):

Takes the raw news items from fetch_news
Sends them to the LLM with a structured prompt:
Output format: Markdown
Date headers (YYYY-MM-DD in IST)
Concise summary per article
Source URL as a link
Sorted latest-first
Stores the LLM response in state['summary']
save_result node (AINewsNode.save_result):

Writes ./AINews/{frequency}_summary.md with the summary
After graph completion, display_result.py reads this file and renders it with st.markdown()
UI Configuration System
All UI text and options come from uiconfigfile.ini
 — nothing is hardcoded in the Streamlit code.

ini

[DEFAULT]
PAGE_TITLE = LangGraph: Build Stateful Agentic AI LangGraph
LLM_OPTIONS = Groq
USECASE_OPTIONS = Basic Chatbot, Chatbot With Web, AI News
GROQ_MODEL_OPTIONS = groq/compound, openai/gpt-oss-120b
The Config class in uiconfigfile.py reads this file using ConfigParser and exposes four getter methods. LoadStreamlitUI uses these getters to build all dropdowns and labels.

To add a new LLM option or use case — update the .ini file. The UI picks it up automatically without touching any Streamlit code.


## Adding a New Use Case
1. Create a node file in nodes/ with your logic
2. Add a new graph-building method in graph_builder.py
3. Register the use case name in uiconfigfile.ini under USECASE_OPTIONS
4. Add a display branch in display_result.py
5. If the use case needs a new API key, add the input field in loadui.py

## Key Design Decisions
Why LangGraph over plain LangChain? 
LangGraph gives you explicit control over state transitions. You can see exactly which node runs when, add conditional routing, and build loops — none of which is straightforward with LangChain's sequential chains.

Why Groq? 
Groq's inference API is significantly faster than most alternatives for open-weight models. It has a generous free tier which makes this project runnable without any cost.

Why Tavily for news fetching instead of RSS or scraping? 
Tavily returns structured, pre-filtered results with metadata (URL, date, content snippet) in a single API call. It handles the complexity of news aggregation so the code stays focused on the agentic pipeline.

Why save AI News output to a .md file? 
It decouples the generation step from the display step. The graph writes the file; the UI reads it. This means you can also access the summary outside the app, commit it, or diff it over time.

