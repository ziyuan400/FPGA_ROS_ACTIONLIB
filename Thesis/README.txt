% ===============================================
% README for LaTeX Thesis Template
%
% Author: Julian Haase
% E-Mail: Julian.Haase@tu-dresden.de
% Date: 25.04.2018
% Please contact the author in case of questions.
% ===============================================
Content of this folder
======================

- abstract.tex 
- acronyms.tex
- Aufgabenstellung.pdf
- header.tex -> do not touch if you don't know what are you doing
- README.txt
- symbols.tex
- thesis.pdf -> PDF to get an idea how it looks like
- thesis.tex -> main file of the LaTeX template
- titlepage.tex
- appendix/appendix.tex
- bib/references.bib
- chapters/introduction.tex
- chapters/main.tex
- chapters/summary.tex
- figures/dreieck.png
- figures/Si-function.png
- figures/tiefpass.png
- figures/tikz/PLACE_HERE_YOUR_TIKZ_FILES.txt
- tables/HERE_YOU_CAN_PUT_BIG_TABLES.txt

Template for a task
=========================

- This folder consists of a template to make a thesis with LaTeX.
- Make changes depending on your needs.
- Look at the comments in the tex-file for more details.
- Compiling order in TeXstudio: PdfLaTeX, Makeglossaries, PdfLaTeX
- Compiling order general: PdfLaTeX, Biber, PdfLaTeX, PdfLaTeX, Makeglossaries, PdfLaTeX
- Compiling: pdflatex, bibtex, pdflatex, pdflatex

Requirements
============

- PdfLaTeX
- texlive-science
- texlive-bibtex-extra
- biber
- tested with TeXstudio 2.12.6, MiKTeX 2.9, Windows 10
- other version not tested
