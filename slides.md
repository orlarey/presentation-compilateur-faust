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

# Arbres

- symbols : tlib/symbol.hh+cpp
- nodes : tlib/node.hh+cpp
- trees : tlib/tree.hh+cpp, 2 types de recursivité (de Bruijn+ symbolique)
- constructeurs
- destructurateurs
- propriétés

# Arbres : exemple de la composition séquentielle `A:B`

	gGlobal->BOXSEQ = symbol("BoxSeq");

	Tree boxSeq(Tree x, Tree y)
	{
		return tree(gGlobal->BOXSEQ, x, y);
	}
	bool isBoxSeq(Tree t, Tree& x, Tree& y)
	{
		return isTree(t, gGlobal->BOXSEQ, x, y);
	}


# Arbres : récursivité _de Bruijn_

	
	Tree rec(Tree body)
	{    return tree(gGlobal->DEBRUIJN, body); }

	bool isRec(Tree t, Tree& body)
	{	return isTree(t, gGlobal->DEBRUIJN, body); }

	Tree ref(int level)
	{	return tree(gGlobal->DEBRUIJNREF, tree(level)); }

	bool isRef(Tree t, int& level)
	{
		Tree u;
		if (isTree(t, gGlobal->DEBRUIJNREF, u)) {
			return isInt(u->node(), &level);
		} else {
			return false;
		}
	}


# Arbres : récursivité _symbolique_

	Tree rec(Tree var, Tree body) {	
		Tree t = tree(gGlobal->SYMREC, var);
		t->setProperty(gGlobal->RECDEF, body);
		return t; }

	bool isRec(Tree t, Tree& var, Tree& body) {
		if (isTree(t, gGlobal->SYMREC, var)) {
			body = t->getProperty(gGlobal->RECDEF);
			return true;
		} else {
			return false; } }

	Tree ref(Tree id) { return tree(gGlobal->SYMREC, id); }

	bool isRef(Tree t, Tree& v) { 
		return isTree(t, gGlobal->SYMREC, v); }

  
# Parsing Lex/Yacc

- Chargeur récursif, utilisation des url

# Structure d'une primitive processeur de signaux
bla bla
# Propagation symbolique
bla bla
![](examples/ex1.pdf)



