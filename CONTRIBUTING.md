# Contributing

Thanks for checking this out. Here's everything you need to contribute.

---

## Getting Started

1. Fork the repository
2. Follow the setup steps in [README.md](./README.md) to get it running locally
3. Explore the codebase — [ARCHITECTURE.md](./ARCHITECTURE.md) explains how it's structured

---

## How to Contribute

# Create a feature branch
git checkout -b feature/your-feature-name

# Make your changes, then commit
git commit -m "feat: describe what you added"

# Push and open a Pull Request against main
git push origin feature/your-feature-name

# Code Guidelines
- Add a docstring to every class and public method
- Keep node logic in nodes/, graph wiring in graph_builder.py, and display logic in display_result.py - don't mix concerns
- New use cases should follow the same pattern: node file → graph method → .ini entry → display branch
- Do not commit .env files or API keys under any circumstances

# Commit Message Format
- feat: short description of new feature
- fix: short description of bug fix
- docs: documentation-only change
- refactor: code change with no behavior change
- chore: dependency updates, config changes

# Pull Request Checklist
Before opening a PR:
 - The app runs without errors (streamlit run app.py)
 - New logic has a docstring
 - No API keys or .env files are committed
 - The PR description explains what changed and why

