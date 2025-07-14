## LOC
```shell
cloc lib/src/ --fullpath --not-match-d='lib/src/highlighting/languages/*'
```

### Status:
- [x] Lsp Completion
- [x] Lsp Hover
- [x] Lsp Code Actions
- [x] Lsp Diagnostics
- [x] Code Highlighting
- [x] Selection
- [x] Input System using actions
- [x] undo/redo stack
- [] Automatic Bracket Insertion
- [] StatusBar
- [] Git Integration
- [] ToolBar
- [] Split Code Windows
- [] Find and Replace
- [] Folding
- [] lsp outlines
- [] lsp formatting
- [] Bracket pair highlighting
- [] lsp rename
- [] dap
- [] make lsp client typesafe
- [] tree sitter

### Bugs/Enhancements:
- [] redo doesnt work for multiline perfectly
- [] move viewport when scrolling out of view
- [] when scrolling for a longer time, increase scroll speed