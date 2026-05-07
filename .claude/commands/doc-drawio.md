---
description: Auto-generate drawio diagrams + Vietnamese docs for the current repo
argument-hint: "[path] [--skip-render] [--focus=<topic>]"
---

You will produce visual documentation for a code repository using drawio. This command is self-contained — do not rely on any memory from previous sessions.

Arguments (if any): `$ARGUMENTS`
- A path → treat it as target repo (cd there); otherwise use current working directory.
- `--skip-render` → stop after validating the `.drawio` file; don't install drawio or render images.
- `--focus=<topic>` → add an extra diagram page specifically for that topic (e.g. `--focus=auth-flow`, `--focus=deployment`, `--focus=payment`).

## Workflow — follow in order

**1. Stack detection.** Read `README.md` (or `README*`) plus the manifest file(s) that exist: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `Gemfile`, `composer.json`, `build.gradle`. Identify language/framework/DB from what you find.

**2. Code walk.** Glob the top of the repo, then read key entry points in the conventional folders for that stack:
- Node/TS: `app/`, `src/`, `components/`, `lib/`, `types/`, `api/`, `pages/`
- Python: `src/`, package-named folder, `tests/`, entry module
- Go: `cmd/`, `internal/`, `pkg/`
- Rust: `src/`, `crates/*/src/`

Cap at ~20 file reads. Use `Grep` to locate symbols rather than reading everything. Also scan for: SQL schema files, Dockerfile, CI config, env samples — they reveal external dependencies.

**3. Design the diagrams** (4 base + 1 optional):
- **Page 1 — Architecture overview**: users / clients → app tier → external services (DB, auth, queues, third-party APIs). Group by deployment boundary.
- **Page 2 — Primary runtime flow**: pick the single most load-bearing code path (main request, auth handshake, job pipeline) and draw the sequence top-to-bottom with decision diamonds where branching matters.
- **Page 3 — Data model (ERD)**: if SQL DB present, draw tables with columns + PK/FK + relations (entity-relation edge style). If no SQL, draw the main data shapes / message types instead. Skip only if genuinely no data model.
- **Page 4 — Directory structure + relationships**: tree of top-level dirs + dashed "uses" edges between nodes where a file imports/depends on another.
- **Page 5 (if `--focus=<topic>`)**: extra diagram just for that subsystem.

**4. Write the drawio file** → `docs/architecture.drawio` (create `docs/` if missing).

mxGraph XML format:
```
<mxfile host="cli-anything" agent="cli-anything-drawio/1.0.0" version="24.0.0">
  <diagram id="d1-<slug>" name="1. <Title>">
    <mxGraphModel dx="1400" dy="900" grid="1" gridSize="10" page="1" pageWidth="1400" pageHeight="900">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- shapes and edges here -->
      </root>
    </mxGraphModel>
  </diagram>
  <!-- more <diagram> pages -->
</mxfile>
```

Rules:
- Every shape: `<mxCell vertex="1" parent="1" style="..."><mxGeometry x y width height .../></mxCell>`
- Every edge: `<mxCell edge="1" source="<id>" target="<id>" parent="1" style="..."><mxGeometry relative="1" as="geometry"/></mxCell>`
- Enable HTML labels with `html=1` in style; use `&lt;br&gt;` for line breaks inside the `value` attribute (XML-escape).
- Unique cell IDs within each diagram; IDs `0` and `1` are reserved.
- Useful styles:
  - rectangle: `rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;`
  - container (group box): add `strokeWidth=2;verticalAlign=top;fontStyle=1;fillColor=none;`
  - actor: `shape=umlActor;verticalLabelPosition=bottom;verticalAlign=top;html=1;`
  - database: `shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;`
  - decision: `rhombus;whiteSpace=wrap;html=1;`
  - note: `shape=note;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;`
  - document: `shape=document;whiteSpace=wrap;html=1;`
  - orthogonal edge: `edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;endArrow=classic;`
  - ER edge: `edgeStyle=entityRelationEdgeStyle;html=1;endArrow=ERmany;startArrow=ERone;`

Color legend stay consistent across repos: blue `#dae8fc` = server/backend, green `#d5e8d4` = client/frontend, yellow `#fff2cc` = shared libs, red `#f8cecc` = types/interfaces, purple `#e1d5e7` = data / SQL artifacts, gray `#f5f5f5` = external services.

**5. Validate the XML:**
```bash
python3 -c "import xml.etree.ElementTree as ET; t=ET.parse('docs/architecture.drawio'); print('pages:', len(t.getroot().findall('diagram')))"
```
If parsing fails, fix and revalidate. Do not proceed until clean.

**6. Render** (skip if `--skip-render`):

Check `which drawio`. If missing on macOS: `brew install --cask drawio` (ask the user first if you're unsure whether they want to install). On Linux: suggest the user install drawio-desktop from releases.

Once available:
```bash
cd docs
drawio -x -a -f pdf -o rendered/architecture.pdf architecture.drawio
N=$(python3 -c "import xml.etree.ElementTree as ET; print(len(ET.parse('architecture.drawio').getroot().findall('diagram')))")
for i in $(seq 1 $N); do
  drawio -x -p $i -f png --border 20 -o "rendered/page-${i}.png" architecture.drawio
  drawio -x -p $i -f svg --border 20 -o "rendered/page-${i}.svg" architecture.drawio
done
```

Ignore Electron `SharedImageManager`/GPU stderr — files still write correctly. Verify file sizes > 10 KB per PNG as a sanity check.

**7. Write `docs/DOCUMENTATION.md`** — Vietnamese prose, English technical terms. Structure:

```
# <Project name> — Tài liệu kiến trúc

## Cách mở & render sơ đồ
(link to .drawio + mention rendered/ folder + re-render command)

## 1. Kiến trúc tổng quan
![...](rendered/page-1.png)
<3-5 paragraphs explaining *why* the architecture is the way it is, constraints, trade-offs>

## 2. <runtime flow name>
![...](rendered/page-2.png)
<numbered steps + non-obvious constraints>

## 3. Data model
![...](rendered/page-3.png)
<table of key relations + invariants>

## 4. Cấu trúc thư mục
![...](rendered/page-4.png)
<tree + principles>

## (optional) 5. <focus topic>
![...](rendered/page-5.png)

## Các ràng buộc & quyết định không nhìn thấy trong code
<bullet list of non-obvious decisions you spotted>

## Roadmap tài liệu
<how to update each page when code changes>
```

Prioritize **why over what**: readers can see *what* the code does; they need you to tell them *why* it's shaped this way.

## Non-negotiables

- Use drawio (not mermaid, not plantuml, not ASCII art).
- Validate `.drawio` XML before rendering.
- If render fails, keep the `.drawio` file anyway — user can open it manually in app.diagrams.net.
- Vietnamese prose; English for identifiers, file paths, SQL, API names.
- Don't invent features. Only document what's actually in the code. When uncertain, say so in the doc.
