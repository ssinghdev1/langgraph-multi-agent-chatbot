# Contributing

Thanks for your interest. Here's everything you need to get started.

---

## Getting Started

1. Fork this repository
2. Follow the setup steps in [README.md](./README.md) to run it locally
3. Read [ARCHITECTURE.md](./ARCHITECTURE.md) to understand how the code is structured before making changes

---

## How to Contribute

```bash
# 1. Create a feature branch
git checkout -b feature/your-feature-name

# 2. Make your changes

# 3. Commit with a clear message
git commit -m "feat: describe what you added"

# 4. Push and open a Pull Request against main
git push origin feature/your-feature-name
```

---

## Good First Issues

These are good starting points if you're new to the codebase:

- Add a new use case (document Q&A, code assistant, stock news)
- Add conversation memory that persists across sessions
- Add support for a second LLM provider (OpenAI, Anthropic, Ollama)
- Write unit tests for individual node logic in `nodes/`
- Improve error messages when an API key is wrong or expired
- Add a copy-to-clipboard button for AI News summaries

---

## Code Guidelines

- Follow PEP 8
- Add a docstring to every class and public method
- Keep node logic in `nodes/`, graph wiring in `graph_builder.py`, and display logic in `display_result.py` — do not mix concerns
- New use cases follow this pattern: node file → graph method → `.ini` entry → display branch
- Never commit `.env` files or API keys

---

## Commit Message Format

```
feat: short description      # new feature
fix: short description       # bug fix
docs: short description      # documentation only
refactor: short description  # code change, no behavior change
chore: short description     # dependency updates, config changes
```

---

## Pull Request Checklist

- [ ] App runs without errors (`streamlit run app.py`)
- [ ] New classes and methods have docstrings
- [ ] No API keys or `.env` files are committed
- [ ] PR description explains what changed and why

---

## Questions

Open an issue and label it `question`. Response time is typically within a few days.