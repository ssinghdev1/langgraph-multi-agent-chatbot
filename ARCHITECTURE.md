# Architecture

This document covers the end-to-end application flow, state design, all three LangGraph graphs, and the UI configuration system.

---

## End-to-End Flow

```
User opens browser
        │
        ▼
app.py  ──►  load_langgraph_agenticai_app()  (main.py)
        │
        ▼
LoadStreamlitUI.load_streamlit_ui()  (loadui.py)
  - Renders sidebar: LLM selector, model selector, API keys
  - Renders use case selector
  - For AI News: renders timeframe selector + Fetch button
  - Returns user_controls dict
        │
        ▼
GroqLLM(user_control_input).get_llm_model()  (groqllm.py)
  - Reads GROQ_API_KEY and selected_groq_model from user_controls
  - Returns a ChatGroq instance
        │
        ▼
GraphBuilder(model).setup_graph(usecase)  (graph_builder.py)
  - Picks the correct graph-building method based on usecase string
  - Compiles and returns a runnable LangGraph graph
        │
        ▼
DisplayResultStreamlit.display_result_on_ui()  (display_result.py)
  - Streams or invokes the compiled graph
  - Renders output in Streamlit chat UI based on use case
        │
        ▼
User sees response
```

---

## Shared State

All graphs use the same `State` TypedDict defined in `state/state.py`:

```python
class State(TypedDict):
    messages: Annotated[List, add_messages]
```

`add_messages` is a LangGraph reducer. Instead of replacing the messages list on each update, it appends to it. This is what gives the chatbot memory within a session — every node return is accumulated, not overwritten.

---

## Graph 1 — Basic Chatbot

**Files:** `nodes/basic_chatbot_node.py`, `graph/graph_builder.py`

```
START → chatbot → END
```

**chatbot node** (`BasicChatbotNode.process`):
Calls `llm.invoke(state['messages'])` and returns the AI response.
The `add_messages` reducer accumulates the full conversation history automatically.

**Use when:** Simple Q&A with no need for live data or external tools.

---

## Graph 2 — Chatbot With Web

**Files:** `nodes/chatbot_with_tool_node.py`, `tools/search_tool.py`, `graph/graph_builder.py`

```
START
  │
  ▼
chatbot ──── (LLM emits tool call?) ──YES──► tools
  ▲                                              │
  │                                              │
  └──────────────────────────────────────────────┘
  │
  NO
  │
  ▼
 END
```

**chatbot node** (`ChatbotWithToolNode.create_chatbot`):
The LLM is bound to Tavily via `.bind_tools(tools)`. If it decides a search is needed, it emits a tool call message instead of a direct answer.

**tools node** (`ToolNode` from `langgraph.prebuilt`):
Executes the Tavily search and returns a `ToolMessage` with the result back to `chatbot`.

**Routing — `tools_condition`** (LangGraph built-in):
Reads the last message. Tool calls present → route to `tools`. No tool calls → route to `END`.

The `tools → chatbot` loop lets the LLM reason over search results and decide whether to answer or search again.

**Tool definition in `search_tool.py`:**

```python
def get_tools():
    return [TavilySearch(max_result=2)]

def create_tool_node(tools):
    return ToolNode(tools=tools)
```

---

## Graph 3 — AI News Pipeline

**Files:** `nodes/ai_news_node.py`, `graph/graph_builder.py`

```
START → fetch_news → summarize_news → save_result → END
```

This is a fully automated pipeline. The user selects a time frame and clicks a button — the graph runs end-to-end without any further user input.

**fetch_news node** (`AINewsNode.fetch_news`):

- Reads `frequency` from the first message (`daily` / `weekly` / `monthly`)
- Maps frequency to Tavily params:

| Frequency | time_range | days |
|---|---|---|
| daily | `d` | 1 |
| weekly | `w` | 7 |
| monthly | `m` | 30 |

- Calls Tavily with:
  - Query: `"Top Artificial Intelligence (AI) technology news India and globally"`
  - Topic: `news`
  - Max results: `20`
  - `include_answer: "advanced"`
- Stores results in `state['news_data']`

**summarize_news node** (`AINewsNode.summarize_news`):

- Takes the raw news items
- Sends them to the LLM with a structured prompt asking for:
  - Markdown output
  - Date headers in `YYYY-MM-DD` format (IST)
  - One concise summary sentence per article
  - Source URL as a clickable link
  - Sorted latest-first
- Stores the response in `state['summary']`

**save_result node** (`AINewsNode.save_result`):

- Writes `./AINews/{frequency}_summary.md`
- After the graph finishes, `display_result.py` reads this file and renders it with `st.markdown()`

---

## UI Configuration System

All UI labels, options, and model names live in `ui/uiconfigfile.ini`. Nothing is hardcoded in the Streamlit code.

```ini
[DEFAULT]
PAGE_TITLE = LangGraph: Build Stateful Agentic AI LangGraph
LLM_OPTIONS = Groq
USECASE_OPTIONS = Basic Chatbot, Chatbot With Web, AI News
GROQ_MODEL_OPTIONS = groq/compound, openai/gpt-oss-120b
```

The `Config` class (`uiconfigfile.py`) reads this file using `ConfigParser` and exposes four getter methods. `LoadStreamlitUI` uses these getters to build all dropdowns and labels dynamically.

To add a new model or use case — update the `.ini` file. The UI picks it up automatically.

---

## Adding a New Use Case

1. Create a node file in `nodes/` with your logic
2. Add a graph-building method in `graph_builder.py`
3. Add the use case name to `USECASE_OPTIONS` in `uiconfigfile.ini`
4. Add a display branch in `display_result.py`
5. If a new API key is needed, add the input field in `loadui.py`

---

## Design Decisions

**Why LangGraph instead of plain LangChain?**
LangGraph gives explicit control over state transitions. You can see exactly which node runs when, add conditional routing, and build loops — things that are difficult to do cleanly with LangChain's sequential chains.

**Why Groq?**
Groq's inference API is significantly faster than most alternatives. It has a generous free tier, which makes this project runnable with zero cost.

**Why Tavily for news instead of RSS or scraping?**
Tavily returns structured results with metadata (URL, date, content) in a single API call and handles aggregation internally. It keeps the pipeline code focused on the agentic logic, not data wrangling.

**Why write AI News output to a `.md` file?**
It decouples generation from display. The graph writes the file; the UI reads it. The summary is also accessible outside the app — you can open it, commit it, or diff summaries over time.

