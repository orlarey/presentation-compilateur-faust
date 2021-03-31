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

Arbres non-mutables, hash-consing, DAG, propriétés mutables. 

Propriété des arbres : $t_1 = t_2 \Leftrightarrow M(t_1) = M(t_2)$ 

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

- `parser/faustlexer.l`
- `parser/faustparser.y`
- `libcode.cpp/parseSourceFiles()`
- `parser/sourcereader.hh/SourceReader`
- environnement
- Chargeur récursif, utilisation des url

# Parsing

Parsing de l'expression `library("math.lib")` :

	(G := gGlobal)
	const char* fname = tree2str(label);
	Tree eqlst = G->gReader.expandList(G->gReader.getList(fname));
	Tree res   = closure(boxEnvironment(), G->nil, G->nil,
				      pushMultiClosureDefs(eqlst, G->nil, G->nil));
	setDefNameProperty(res, label);
	return res;


# Environnements

Les définitions d'un programme sont organisées en environnements par `pushMultiClosureDefs()` :

![](images/faust-def-env.pdf)


# Evaluation

Evaluation de la définition de `process` dans l'environnement résultant de la lecture des fichiers sources (voir `eval.cpp`) :

	Tree evalprocess(Tree eqlist)
	{
		Tree b=a2sb(eval(boxIdent(G->gProcessName.c_str()), G->nil,
					pushMultiClosureDefs(eqlist, G->nil, G->nil)));

		if (G->gSimplifyDiagrams) {
			b = boxSimplification(b);
		}

		return b;
	}

# Exemple d'évaluation

	repeat(1,f) = f;
	repeat(n,f) = f <: _, repeat(n-1,f) :> _;

	N = 6/2;
	FX = mem;
	process = repeat(N,FX);

# Forme Normale

Le résultat de l'évaluation est un circuit _en forme normale_ ou ne subsiste qu'une composition de primitives : 

	mem <: _, (mem <: _, mem :> _) :> _

Le diagramme SVG est la représentation graphique (éventuellement hiérarchisée) de la forme normale :

![](examples/ex2.pdf)

# Les abstractions restantes (non appliquées) sont transformées en routage

Exemple :

	rsub(x,y,z) = y - x*z;
	process = rsub(0.5);

![](examples/ex4.pdf)

# Propagation Symbolique

Le but de la propagation symbolique est d'exprimer les signaux de sortie en fonction des signaux d'entrée.

![](graphs/ex2.pdf)

# Normalisation des signaux


# Types des signaux

Type d'un signal $s$ = Variabilité $\times$ Nature $\times$ Calculabilité

- **Variabilité** : $K$ (constant) $\subset$ $B$ (bloc/contrôle) $\subset$ S (sample)
- **Nature** : $Z$ (entier) $\subset$  $R$ (réel)
- **Calculabilité** : $C$ (compilation) $\subset$  $I$ (initialisation) $\subset$  $X$ (exécution)


# Les types forment un treillis 

![](images/types-lattice2.pdf)

# Type d'un signal, informations additionnelles

- **Vectorabilité** : $V\subset\widehat{V}$ peut être calculé en parallèle ou pas
- **Booléen** : $B\subset\widehat{B}$ représente un signal booléen ou pas
- **Intervalle** : les valeurs du signal $s(t)$ sont contenues dans l'intervalle $[l,h]$:  $\forall t\in\mathbb{N}, l \leq s(t) \leq h$
  

# Type du signal produit par `(1 : (+ : min(3)) ~ _)`

$[\![$ `1 : (+ : min(3)) ~ _` $]\!] = ()\rightarrow z$

![](examples/ex1-annotated.pdf)


Type de $z(t) : SZC\widehat{V}\widehat{B}[1,3]$

# Intervalle d'un signal récursif

En réalité, on ne calcule pas réellement l'intervalle d'un signal récursif, on renvoie simplement $[-\infty,+\infty]$. Ce qu'il faudrait faire :

![](examples/ex2-annotated.pdf)

- $J_0=F([0,0],X_0)$, $J_1=F(J_0,X_1)$, \ldots, $J_n=F(J_{n-1},X_n)$
- $J = \bigcup\limits_{i=0}^{\infty} J_{i}$, $X = \bigcup\limits_{i=0}^{\infty} X_{i}$
  
- $J \subseteq I=F([0,0]\cup I,X)$
 
