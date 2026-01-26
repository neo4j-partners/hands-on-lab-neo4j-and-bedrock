# Expanded Context Pattern

## The Problem

When you find a relevant chunk, it may be mid-sentence or mid-thought:

```
Chunk 2: "...faces significant cybersecurity risks including..."
```

## The Solution

Traverse `NEXT_CHUNK` to get surrounding context:

```
[Chunk 1: Setup]  →  [Chunk 2: Matched]  →  [Chunk 3: Details]
```

Concatenated, this gives the LLM complete context.

## Why This Matters

Consider: "What were Apple's revenue trends?"

- **Matched chunk**: Mentions a specific quarter
- **Previous chunk**: Setup and context
- **Next chunk**: Conclusions and follow-up

The LLM gets **three times the context** for better answers.

---

[← Previous](13-vector-cypher.md) | [Next: The GraphRAG Class →](15-graphrag-class.md)
