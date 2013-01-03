/*
 * cssparse.c --
 *
 *     This file contains a lemon parser syntax for CSS stylesheets as parsed
 *     by Tkhtml.
 *
 *----------------------------------------------------------------------------
 * Copyright (c) 2005 Eolas Technologies Inc.
 * All rights reserved.
 *
 * This Open Source project was made possible through the financial support
 * of Eolas Technologies Inc.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <ORGANIZATION> nor the names of its
 *       contributors may be used to endorse or promote products derived from
 *       this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

%name tkhtmlCssParser
%extra_argument {CssParse *pParse}
%include {
#include "cssInt.h"
#include <string.h>
#include <ctype.h>
}

/* Token prefix 'CT' stands for Css Token. */
%token_prefix CT_
%token_type {CssToken}

/* Need this value for a trick in the tokenizer used to parse CT_FUNCTION. */
%nonassoc RRP. 

%syntax_error {
    pParse->pStyle->nSyntaxErr++;
    pParse->isIgnore = 0;
    /* HtmlCssRule(pParse, 0); */
}

/* Style sheet consists of a header followed by a body. */
stylesheet ::= ss_header ss_body.

/* Optional whitespace. */
ws ::= .
ws ::= SPACE ws.

/*********************************************************************
** Style sheet header. Contains @charset and @import directives. @charset
** directives are ignored for the time being.
*/
ss_header ::= ws charset_opt imports_opt.

charset_opt ::= CHARSET_SYM ws STRING ws SEMICOLON ws.
charset_opt ::= .

imports_opt ::= imports_opt IMPORT_SYM ws term(X) medium_list_opt SEMICOLON ws.
{
    HtmlCssImport(pParse, &X);
}
imports_opt ::= .
imports_opt ::= unknown_at_rule.

medium_list_opt ::= medium_list.
medium_list_opt ::= .

/*
 * Code to handle an unknown "at-rule". If the tokenizer sees an "@" 
 * character that is not followed by any known at-keyword, it calls
 * the "@" an UNKNOWN_SYM token. The correct behaviour is to discard
 * everything up until the next semicolon or the end of the next
 * block.
 */
unknown_at_rule ::= UNKNOWN_SYM trash SEMICOLON ws.
unknown_at_rule ::= UNKNOWN_SYM trash LP trash RP ws.
trash ::= .
trash ::= error.
trash ::= trash error.

/*********************************************************************
** Style sheet body. A list of style sheet body items.
*/
/*
ss_body ::= .
ss_body ::= ss_body_item ws ss_body.
*/

ss_body ::= ss_body_item.
ss_body ::= ss_body ws ss_body_item.

ss_body_item ::= media.
ss_body_item ::= ruleset.
ss_body_item ::= font_face. 

/*********************************************************************
** @media {...} block.
*/
media ::= MEDIA_SYM ws medium_list LP ws ruleset_list RP. {
    pParse->isIgnore = 0;
}

%type medium_list {int}
%type medium_list_item {int}

medium_list_item(A) ::= IDENT(X). {
    if (
        (X.n == 3 && 0 == strnicmp(X.z, "all", 3)) ||
        (X.n == 6 && 0 == strnicmp(X.z, "screen", 6))
    ) {
        A = 0;
    } else {
        A = 1;
    }
}

medium_list(A) ::= medium_list_item(X) ws. {
    A = X;
    pParse->isIgnore = A;
}

medium_list(A) ::= medium_list_item(X) ws COMMA ws medium_list(Y). {
    A = (X && Y) ? 1 : 0;
    pParse->isIgnore = A;
}

/*********************************************************************
** @page {...} block. 
*/
page ::= page_sym ws pseudo_opt LP declaration_list RP. {
  pParse->isIgnore = 0;
}

pseudo_opt ::= COLON IDENT ws.
pseudo_opt ::= .

page_sym ::= PAGE_SYM. {
  pParse->isIgnore = 1;
}

/*********************************************************************
** @font_face {...} block.
*/
font_face ::= FONT_SYM LP declaration_list RP.

/*********************************************************************
** Style sheet rules. e.g. "<selector> { <properties> }"
*/
ruleset_list ::= ruleset ws.
ruleset_list ::= ruleset ws ruleset_list.

ruleset ::= selector_list LP declaration_list RP. {
    HtmlCssRule(pParse, 1);
}
ruleset ::= page.

selector_list ::= selector.
selector_list ::= selector_list comma ws selector.
comma ::= COMMA. {
    HtmlCssSelectorComma(pParse);
}

declaration_list ::= declaration.
declaration_list ::= declaration_list SEMICOLON declaration.
declaration_list ::= declaration_list SEMICOLON ws.

declaration ::= ws IDENT(X) ws COLON ws expr(E) prio(I). {
    HtmlCssDeclaration(pParse, &X, &E, I);
}
declaration ::= garbage.

garbage ::= garbage_token.
garbage ::= garbage garbage_token.
garbage_token ::= error.
garbage_token ::= LP garbage RP.

%type prio {int}
prio(X) ::= IMPORTANT_SYM ws. {X = (pParse->pStyleId) ? 1 : 0;}
prio(X) ::= .                 {X = 0;}

/*********************************************************************
** Selector syntax. This is in a section of it's own because it's
** complicated.
*/
selector ::= simple_selector ws.
selector ::= simple_selector combinator selector.

/* 
 * CSS Selector Grammar Summary:
 *
 *     <selector>        := <simple-selector> ?<combinator> <selector>?
 *     <combinator>      := "+" | ">" | " " 
 *     <simple-selector> := <tag> <s-selector-tail>
 *     <tag>             := "*" | id | ""
 *     <s-selector-tail> := (#id | .id | :id | [id] | [id <sym> string])*
 *     <sym>             := "=" | "|=" | "~="
 */

combinator ::= ws PLUS ws. {
    HtmlCssSelector(pParse, CSS_SELECTORCHAIN_ADJACENT, 0, 0);
}
combinator ::= ws GT ws. {
    HtmlCssSelector(pParse, CSS_SELECTORCHAIN_CHILD, 0, 0);
}
combinator ::= SPACE ws. {
    HtmlCssSelector(pParse, CSS_SELECTORCHAIN_DESCENDANT, 0, 0);
}

simple_selector ::= tag simple_selector_tail.
simple_selector ::= simple_selector_tail.
simple_selector ::= tag.

tag ::= IDENT(X).     { HtmlCssSelector(pParse, CSS_SELECTOR_TYPE, 0, &X); }
tag ::= STAR.         { HtmlCssSelector(pParse, CSS_SELECTOR_UNIVERSAL, 0, 0); }
tag ::= SEMICOLON(X). { HtmlCssSelector(pParse, CSS_SELECTOR_TYPE, 0, &X); }

simple_selector_tail ::= simple_selector_tail_component.
simple_selector_tail ::= simple_selector_tail_component simple_selector_tail.

simple_selector_tail ::= error. {
    HtmlCssSelector(pParse, CSS_SELECTOR_NEVERMATCH, 0, 0);
}

simple_selector_tail_component ::= HASH IDENT(X). {
    HtmlCssSelector(pParse, CSS_SELECTOR_ID, 0, &X);
}
simple_selector_tail_component ::= DOT IDENT(X). {
    /* A CSS class selector may not begin with a digit. Presumably this is
     * because they expect to use this syntax for something else in a
     * future version. For now, just insert a "never-match" condition into
     * the rule to prevent it from having any affect. A bit lazy, this.
     */
    if (X.n > 0 && !isdigit((int)(*X.z))) {
        HtmlCssSelector(pParse, CSS_SELECTOR_CLASS, 0, &X);
    } else {
        HtmlCssSelector(pParse, CSS_SELECTOR_NEVERMATCH, 0, 0);
    }
}
simple_selector_tail_component ::= LSP IDENT(X) RSP. {
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTR, &X, 0);
}
simple_selector_tail_component ::= LSP IDENT(X) EQUALS string(Y) RSP. {
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTRVALUE, &X, &Y);
}
simple_selector_tail_component ::= LSP IDENT(X) TILDE EQUALS string(Y) RSP. {
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTRLISTVALUE, &X, &Y);
}
simple_selector_tail_component ::= LSP IDENT(X) PIPE EQUALS string(Y) RSP. {
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTRHYPHEN, &X, &Y);
}

simple_selector_tail_component ::= COLON IDENT(X). {
    HtmlCssSelector(pParse, HtmlCssPseudo(&X, 1), 0, 0);
}
simple_selector_tail_component ::= COLON COLON IDENT(X). {
    HtmlCssSelector(pParse, HtmlCssPseudo(&X, 2), 0, 0);
}

string(A) ::= STRING(X). {A = X;}
string(A) ::= IDENT(X).  {A = X;}


/*********************************************************************
** Expression syntax. This is very simple, it may need to be extended
** so that the structure of the expression is preserved. At present,
** all stylesheet expressions are stored as strings.
*/
expr(A) ::= term(X) ws.               { A = X; }
expr(A) ::= term(X) operator expr(Y). { A.z = X.z; A.n = (Y.z+Y.n - X.z); }

operator ::= ws COMMA ws.
operator ::= ws SLASH ws.
operator ::= SPACE ws.

term(A) ::= IDENT(X). { A = X; }
term(A) ::= STRING(X). { A = X; }
term(A) ::= FUNCTION(X). { A = X; }
term(A) ::= HASH(X) IDENT(Y). { A.z = X.z; A.n = (Y.z+Y.n - X.z); }

term(A) ::= DOT(X) IDENT(Y).            { A.z = X.z; A.n = (Y.z+Y.n - X.z); }
term(A) ::= IDENT(X) DOT IDENT(Y).      { A.z = X.z; A.n = (Y.z+Y.n - X.z); }
term(A) ::= PLUS(X) IDENT(Y).           { A.z = X.z; A.n = (Y.z+Y.n - X.z); }
term(A) ::= PLUS(X) DOT IDENT(Y).       { A.z = X.z; A.n = (Y.z+Y.n - X.z); }
term(A) ::= PLUS(X) IDENT DOT IDENT(Y). { A.z = X.z; A.n = (Y.z+Y.n - X.z); }
