# LLM-Driven Interactive R Development Workflow

```
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│                  LLM-DRIVEN R DEVELOPMENT WORKFLOW                    │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│                         1. PROJECT SETUP                              │
│                                                                       │
│  ┌─────────────┐    ┌────────────────┐    ┌─────────────────────┐    │
│  │ Create      │───▶│ Start R Server │───▶│ Initialize Logging  │    │
│  │ Structure   │    │                │    │ with sink()         │    │
│  └─────────────┘    └────────────────┘    └─────────────────────┘    │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│                       2. ITERATIVE DEVELOPMENT                        │
│                                                                       │
│   ┌─────────────────────┐                                             │
│   │                     │                                             │
│   │  ┌─────────────┐    │    ┌────────────────┐    ┌──────────────┐  │
│   │  │ LLM proposes│    │    │ Execute via    │    │ Observe      │  │
│   └─▶│ code chunk  │────────▶│ command line   │───▶│ results      │  │
│      └─────────────┘    │    └────────────────┘    └──────────────┘  │
│                         │                                  │          │
│                         │                                  │          │
│      ┌─────────────┐    │    ┌────────────────┐           │          │
│      │ Fix errors  │◀───│────│ Debugging      │◀──────────┘          │
│      │ & improve   │    │    │ needed?   Yes  │                      │
│      └─────────────┘    │    └────────────────┘                      │
│            ▲            │             │                              │
│            │            │             │ No                           │
│            │            │             ▼                              │
│      ┌─────────────┐    │    ┌────────────────┐    ┌──────────────┐  │
│      │ Save to     │◀───│────│ Successful     │───▶│ Document     │  │
│      │ script file │    │    │ code           │    │ reasoning     │  │
│      └─────────────┘    │    └────────────────┘    └──────────────┘  │
│                         │                                             │
└─────────────────────────┼─────────────────────────────────────────────┘
                          │
                          │ Repeat until analysis is complete
                          ▼
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│                       3. DOCUMENTATION                                │
│                                                                       │
│  ┌─────────────┐    ┌────────────────┐    ┌─────────────────────┐    │
│  │ Convert to  │───▶│ Add narrative  │───▶│ Render to HTML/PDF  │    │
│  │ RMarkdown   │    │ & explanations │    │                     │    │
│  └─────────────┘    └────────────────┘    └─────────────────────┘    │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│                       4. REFINEMENT                                   │
│                                                                       │
│  ┌─────────────┐    ┌────────────────┐    ┌─────────────────────┐    │
│  │ Review      │───▶│ Improve        │───▶│ Create final        │    │
│  │ results     │    │ analysis       │    │ report              │    │
│  └─────────────┘    └────────────────┘    └─────────────────────┘    │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Project Setup
- **Create Structure**: Establish project directories for code, data, outputs
- **Start R Server**: Initialize a persistent HTTP/JSON R server
- **Initialize Logging**: Set up sink() for capturing console output

### 2. Iterative Development
- **LLM Proposes Code**: The LLM generates small, targeted code chunks
- **Execute via Command Line**: Code is executed through command-line interface
- **Observe Results**: Output is examined and analyzed
- **Debugging**: Errors are identified and fixed with LLM assistance
- **Save to Script**: Working code is saved to R script files
- **Document Reasoning**: LLM explains analytical decisions and findings

### 3. Documentation
- **Convert to RMarkdown**: Transform R scripts to RMarkdown documents
- **Add Narrative**: Include explanatory text and context
- **Render to HTML/PDF**: Generate publication-ready reports

### 4. Refinement
- **Review Results**: Examine findings for coherence and validity
- **Improve Analysis**: Enhance models or visualizations based on insights
- **Create Final Report**: Produce the final documented analysis

## Key Interactions

1. **LLM ↔ R Server**: The LLM sends commands to the R server via command line
2. **LLM ↔ User**: The LLM explains reasoning and results to the user
3. **User ↔ LLM**: The user provides feedback on analysis direction
4. **R Server ↔ Files**: R server reads/writes data, scripts, and outputs

## Loop Characteristics

1. **State Preservation**: Variables persist between commands
2. **Incremental Development**: Building analysis step by step
3. **Error Recovery**: Immediate feedback and correction
4. **Documentation Trail**: All steps are logged and documented 