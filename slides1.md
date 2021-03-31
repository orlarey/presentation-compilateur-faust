---
author: Yann Orlarey, Stéphane Letz
title: Présentation du compilateur Faust
institute: "![](images/logo-faust.png)"
topic: "Mon sujet"
theme: "Frankfurt"
colortheme: "crane"
fonttheme: "professionalfonts"
fontsize: 10pt
urlcolor: red
linkstyle: bold
date: 1 avril 2021
lang: fr-FR
section-titles: false
toc: false

---

# Les grandes étapes

- Représentations internes basée sur des arbres non mutables et le hash-consing
- Parsing Lex/Yacc
- Evaluation du programme sous la forme d'un circuit de processeurs de signaux
- Propagation symbolique de signaux dans le circuit
- Normalisation et optimisation des signaux
- Typage et calcul d'intervals
- Traduction des signaux en code impératif (FIR)
- Génération du code par le backend choisi

# Traduction des signaux en code impératif (FIR: Faust Imperative Representation)

- gestion mémoire: variables (stack/struct…), tableaux, lecture/écriture
- calculs arithmétiques (unaires/binaires)
- structure de contrôle : for, while, if, switch/case, select…
- structures de données 
- fonctions
- instructif spéciales pour l'UI (construction de sliders/buttons)

# Implémentation

- notions de type, values et statements
- construction d'expressions (avec la classe **InstBuilder**)
- mécanisme de clonage d’une expression
- mécanisme de visiteur pour parcourir une expression

# Transformation FIR => FIR

- renomage ou changement de type (stack/struct...) de variables
- suppressions de cast inutiles 
- inlining de fonctions
- fichiers : 
  - compiler/generator/instructions.hh+cpp
  - compiler/generator/fir_to_fir.hh+cpp

# Traduction signaux =>FIR

- classe **Container** : 
  - remplissage progressif du code FIR pour générer la structure DSP, les différentes fonctions (`init`, `compute`…)
  - sous-classes pour la génération des tables
- classe **InstructionsCompiler** pour la génération de code scalaire
- classe **DAGInstructionsCompiler** pour la génération de code vectorien (DAG de boucles)
  - code vectoriel (boucles reliées par des buffers)
  - code vectoriel et parallèle : pragma pour OpenMP (C/C++) et Work Stealing Scheduler
- fichiers : 
  - compiler/generator/code_container.hh+cpp
  - compiler/generator/instructions_compiler.hh+cpp
  - compiler/generator/dag_instructions_compiler.hh+cpp

# Génération du code par le backend choisi

- traduction du FIR vers le langage cible
- utilise éventuellement des opérations FIR => FIR
- utilise le mécanisme de visiteur

# Backends textuels

- C : génération de structure de données et fonctions (fichiers dans compiler/generator/c)

- C++ : génération d’une classe (fichiers dans compiler/generator/cpp)

- CSharp : génération d’une classe (fichiers dans compiler/generator/csharp)

- Rust : génération d'un type et de méthodes (fichiers dans compiler/generator/rust)

- SOUL : génération d'un processor(fichiers dans compiler/generator/soul)

- ...

  

# Autres backends

- LLVM IR : génération d’un « module LLVM » (fichiers dans compiler/generator/llvm)

- WASM : génération d’un « module WASM » (fichiers dans compiler/generator/wasm)

- ...

  

# Débogage avec le backend FIR

- version textuelle du langage FIR :

  - avec type des variables
  - quelques statistiques sur le code (taille du DSP, nombre d'opérations utilisées)

  

# Instrumentation avec le backend d'Interprétation

- traduction FIR => Faust Byte Code (FBC)
- machine virtuelle d’interprétation du FBC (avec piles et zones mémoires DSP integer/real)
- instrumentation possible

