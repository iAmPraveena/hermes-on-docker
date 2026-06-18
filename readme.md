# Local AI Agent Stack: Hermes + Ollama

A fully self-hosted AI agent platform built using **Hermes Agent** and **Ollama**, with optional support for **Open WebUI** as a browser-based frontend.

## Architecture

Core architecture:

```text
User
  │
  ▼
Hermes Agent
  │
  ▼
Ollama
  │
  ▼
Llama 3.1 8B
```

Optional frontend:

```text
User
  │
  ▼
Open WebUI (Optional)
  │
  ▼
Hermes Agent
  │
  ▼
Ollama
  │
  ▼
Llama 3.1 8B
```

Open WebUI is completely optional. Hermes can be used directly through its CLI, API, automation workflows, or future integrations.

---

## Overview

This project documents the deployment of a local AI agent stack combining Hermes Agent and Ollama running Llama 3.1 8B. The objective was to create a private, extensible, and vendor-independent AI platform capable of reasoning, tool orchestration, workflow automation, and future engineering use cases.

While deployment appeared straightforward, several real-world infrastructure challenges emerged, including Docker networking, corporate proxy interference, model downloads, provider configuration, and container-to-container communication.

The final solution provides a powerful self-hosted AI platform with complete control over models, data, and infrastructure.

---

## Components

### Hermes Agent

Provides:

* Agentic reasoning
* Tool orchestration
* Skill execution
* Workflow automation
* Multi-step planning
* Extensible skill ecosystem

### Ollama

Provides:

* Local model hosting
* OpenAI-compatible APIs
* Model lifecycle management
* Offline inference capability

### Open WebUI (Optional)

Provides:

* Browser-based chat experience
* Conversation history
* Multi-user access
* Model selection interface

---

## Advantages

* Fully local deployment
* No API usage costs
* Complete data privacy
* OpenAI-compatible ecosystem
* Vendor-independent architecture
* Easy model switching
* Docker-based deployment
* Extensible through Hermes skills and toolsets
* Strong foundation for automation and AI-assisted engineering

---

## Tradeoffs

* Additional operational complexity
* Increased memory consumption
* More components to troubleshoot
* Additional latency compared to direct Ollama usage
* Configuration management across multiple services

---

## Challenges Encountered

### Corporate Proxy Interference

Container proxy settings caused internal Docker traffic to be routed externally, resulting in misleading:

```text
DNS lookup failed
```

errors despite Docker networking functioning correctly.

### OpenRouter Fallback

Hermes attempted to use external providers even though the intended deployment was fully local.

This resulted in authentication failures until provider configurations were corrected.

### Model Availability

Hermes successfully connected to Ollama but failed with:

```text
model not found
```

because the model had not been downloaded successfully.

### Agent Overhead

Large system prompts, skill discovery, and orchestration logic introduced additional latency compared to direct model access.

---

## Key Lessons Learned

1. Validate each layer independently:

   * Docker Networking
   * DNS Resolution
   * HTTP Connectivity
   * Ollama APIs
   * Model Availability
   * Hermes Configuration

2. Corporate proxies can silently interfere with container communication.

3. Logs often provide the fastest route to root cause identification.

4. Agent frameworks provide significant capability but introduce operational complexity.

5. Systematic isolation is more effective than trial-and-error debugging.

---

## Future Enhancements

Potential next steps include:

* Robot Framework integration
* Autonomous QA workflows
* RAG over automation repositories
* Test generation from requirements
* Defect triage automation
* CI/CD integrations
* Multi-agent collaboration
* Engineering knowledge assistants

---

## Why This Stack?

This architecture strikes a balance between flexibility and control.

Hermes provides reasoning, planning, and orchestration capabilities while Ollama supplies local inference. Open WebUI can be added when a richer user experience is desired, but it is not required for the core platform.

The resulting solution is suitable for experimentation, automation, AI-assisted engineering, and future autonomous workflow development without dependence on external AI providers.

---

## Repository Structure

```text
.
├── docker-compose.yml
├── config.yaml.example
├── .env.example
├── scripts/
│   ├── install.sh
│   ├── start.sh
│   ├── stop.sh
│   └── validate.sh
├── docs/
│   └── architecture.png
└── README.md
```

---

## Disclaimer

This project is an independent implementation, learning exercise, and deployment reference built using publicly available technologies.

Hermes Agent, Ollama, Open WebUI, and Llama are trademarks, products, or projects owned by their respective organizations and communities. All rights to those names and associated intellectual property belong to their respective owners.

This repository is not affiliated with, sponsored by, endorsed by, or officially associated with Nous Research, Ollama, Open WebUI, Meta, or any related organization.

Any deployment scripts, documentation, troubleshooting notes, architectural diagrams, and lessons learned contained in this repository represent personal experiences derived from deploying and operating these technologies in a self-hosted environment.

No official logos or trademarked artwork are included in this repository.
