# Machinetalk code generator
  This code generator is based on [imatix/gsl](https://github.com/imatix/gsl) and generates code for
  Machinetalk protocol bindings. The idea is that protocol description
  resides in a single model from which documentation and different
  language bindings can be generated.

  Currently machinetalk-gsl supports following languages:
  - Python
  - Qt/C++
  - JavaScript
  - Node.js
  - Markdown and Graphviz

## Directory structure
   The project is organized in the following structure:
   - models: contains all protocol and channel models
   - scripts: contains scripts for the code generator
   - generated: here all the generated code is output
   - generate.sh: fires up the code generator

## Getting started
   - First install gsl by following these [instructions](https://github.com/imatix/gsl#toc3-32).
   - Then install graphviz `sudo apt install graphviz`
   - Fire up `sh generate.sh`

   You can use the `entr` tool to automatically trigger a new build
   when a model changes by issuing following command:

```bash
   ls models/* scripts/* | entr sh -c "sh generate.sh"
```

## Working with the models
   All models are written in standard XML format. The files should be
   pretty self explanatory. I will add a better description once a
   good model has been established.

## Working with the code generators
   The code generators are written in the GSL language. For more
   information follow the tutorials at [GitHub:imatix/gsl](https://github.com/imatix/gsl#starting-with-gsl)

   I found it most useful to use GNU Emacs to edit the gsl
   files. Put the editor into the major-mode for the corresponding language
   (e.g. `python-mode`) and enable the following minor mode by issuing
   `gsl-mode`.

```emacs-lisp
  (define-minor-mode gsl-mode
  "Highlight two successive newlines."
  :global t
  :lighter " gsl"
  (if gsl-mode
      (highlight-regexp "\\(^\\..*\\)\n" 'hi-green-b)
    (unhighlight-regexp "\\(^\\..*\\)\n"))
  (if gsl-mode
      (highlight-regexp "\\(\\$(.*?)\\)" 'hi-red-b)
    (unhighlight-regexp "\\(\\$(.*?)\\)")))
```

I found the electric indent mode very annoying when editing gsl files.
You can easily turn it off by issuing `electric-indent-mode`
