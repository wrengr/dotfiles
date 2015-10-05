% <http://www.icsi.berkeley.edu/ftp/global/pub/speech/jurafsky/lsalike.bst>
%
% BibTeX `lsalike' bibliography style (06-Jan-94)
% 
% Designed by Dan Jurafsky, modified from a version of `apalike.bst' augmented 
% by Michael Braverman.  (The original header of `apalike' follows this one.)
% Copyright (C) 1994, all rights reserved.
% Copying of this file is allowed, provided that if you make any changes at all
% you name it something other than `lsalike.bst'.
% This style should be used with the lsalike.sty style file,
% which generates citations like "Chomsky (1965)" or "Chomsky's (1965)"
% The bibliography format follows the LSA style guide used for the journal 
% Language, except that it includes emphasis in more places than the vanilla LSA does,
% does not put book titles in lower-case, uses ampersands
% for "and" in places, and replaces names by dashes in one more
% situation than LSA style does.   These last two non-standard features
% can be changed back to standard LSA style by changing lsalike.sty.
% See the comment there.
% 
% lsalike Editorial note:
%   Contrary to the opinions of the esteemed original authors,
%   (Susan King and Oren Patashnik) to whom, let me hasten to add,
%   we are all quite grateful, we DO recommend that you use a style
%   like lsalike.  To correct a misrepresentation that appears below,
%   Mary-Claire van Leunen (A Handbook for Scholars, Knopf, 1979)
%   did NOT argue against a style like lsalike, but rather
%   against the traditional practice of including long bibliographic notes
%   directly in the text, or in footnotes.  We agree.  However, we believe
%   that the use of a work's author and year (as is common in linguistics)
%   rather than a `reference number' (which is common in computer science)
%   makes for much easier reading, and much less back-and-forth page-flipping.
%   Thus "Chomsky (1965) argued for the..." is every bit as elegant and
%   terse as "Chomsky [23] argued for the", and much more informative.
%   Similarly, "See Pollard and Sag (1987)" is much clearer than "See [55]",
%   or even "See [Pol87]".  Use of a style like `plain' is extraordinarily
%   frustrating for the reader, especially in the social sciences,
%   which spend a great deal of time dealing with what everybody else said,
%   and in which, as in linguistics for example, everybody knows what
%   "Chomsky (1965)" said, but nobody can be expected to know 
%   what "Chomsky [33]" said.
%	-Dan Jurafsky
%
% BibTeX `apalike' bibliography style (24-Jan-88 version)
% Adapted from the `alpha' style, version 0.99a; for BibTeX version 0.99a.
% Copyright (C) 1988, all rights reserved.
% Copying of this file is allowed, provided that if you make any changes at all
% you name it something other than `apalike.bst'.
% This restriction helps ensure that all copies are identical.
% Differences between this style and `alpha' are generally heralded by a `%'.
% The file btxbst.doc has the documentation for alpha.bst.
%
% This style should be used with the `apalike' LaTeX style (apalike.sty).
% \cite's come out like "(Jones, 1986)" in the text but there are no labels
% in the bibliography, and something like "(1986)" comes out immediately
% after the author.  Author (and editor) names appear as last name, comma,
% initials.  A `year' field is required for every entry, and so is either
% an author (or in some cases, an editor) field or a key field.
%
% Editorial note:
% Many journals require a style like `apalike', but I strongly, strongly,
% strongly recommend that you not use it if you have a choice---use something
% like `plain' instead.  Mary-Claire van Leunen (A Handbook for Scholars,
% Knopf, 1979) argues convincingly that a style like `plain' encourages better
% writing than one like `apalike'.  Furthermore the strongest arguments for
% using an author-date style like `apalike'---that it's "the most practical"
% (The Chicago Manual of Style, University of Chicago Press, thirteenth
% edition, 1982, pages 400--401)---fall flat on their face with the new
% computer-typesetting technology.  For instance page 401 anachronistically
% states "The chief disadvantage of [a style like `plain'] is that additions
% or deletions cannot be made after the manuscript is typed without changing
% numbers in both text references and list."  LaTeX sidesteps the disadvantage.
%
% History:
%   15-sep-86	(SK,OP)	Original version, by Susan King and Oren Patashnik.
%   10-nov-86	(OP)	Truncated the sort.key$ string to the correct length
%			in bib.sort.order to eliminate error message.
%   24-jan-88	(OP)	Updated for BibTeX version 0.99a, from alpha.bst 0.99a;
%			apalike now sorts by author, then year, then title;
%			THIS `apalike' VERSION DOES NOT WORK WITH BIBTEX 0.98i.

ENTRY
  { address
    author
    booktitle
    chapter
    edition
    editor
    howpublished
    institution
    journal
    key
%    month		not used in apalike
    note
    number
    organization
    pages
    publisher
    school
    series
    title
    type
    volume
    year
  }
  {dup lsanewflag}
  { label extra.label sort.label}

INTEGERS { output.state before.all mid.sentence after.sentence after.block after.address}

FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=
  #4 'after.address :=
}

STRINGS { s t start.author last.single.author last.author x y}

% normally add.period doesn't add periods after periods, qms, or bangs.
% This checks for ".)" strings as well, useful for avoiding "Fernandez, Celia (ed.)."
FUNCTION {my.add.period}
{ duplicate$ #-1 #2 substring$ ".)" =
	  'skip$
          'add.period$
	if$
}
 

FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence =
    { ", " * write$ }
    { output.state after.block =
	{ my.add.period write$
	  newline$
	  "\newblock " write$
	}
	{ output.state before.all =
	    'write$
	    {output.state after.address =
		'write$ 
	        { add.period$ " " * write$ }
	      if$
	    }
	  if$
	}
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}

FUNCTION {just.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'skip$
  if$
}

FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull
  if$
}

FUNCTION {output.year.check}
{ year empty$
    { "empty year in " cite$ * warning$ }
    { year extra.label * output}
  if$
}

FUNCTION {format.address}
{ address empty$
    'skip$
    { address ": " * output after.address 'output.state := }
  if$
}

FUNCTION {output.bibitem}
{ newline$
  "\bibitem[" write$       
  label write$
  "]{" write$

  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}

FUNCTION {fin.entry}
{ add.period$
  write$
  newline$
}

FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { after.block 'output.state := }
  if$
}

FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
	'skip$
	{ after.sentence 'output.state := }
      if$
    }
  if$
}

FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}

FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}

FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}

FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { "{\em " swap$ * "\/}" * }
  if$
}

INTEGERS { nameptr namesleft numnames start.num last.num}

FUNCTION {format.rev.names}  % reverse first name in name list
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
  
  % format first name in reverse order	
  s nameptr "{vv~}{ll}{, jj}{, ff}" format.name$ 't :=   % last name first 
  "{\sc " t * "}" * 't := 	% put in small caps for LSA	
  nameptr #1 + 'nameptr :=
  namesleft #1 - 'namesleft :=

  %  if the dup counter is non-zero, replace the first name by 
  %  dashes and decrement the counter
  dup #0 =
    {t}
    { lsanewflag 
		{ "\lsadashifynew{" t * "}" *}
		{ "\lsadashify{" t * "}" *}
      if$
      dup #1 - 'dup :=}
  if$

  
  { namesleft #0 > }
    { s nameptr "{ff~}{vv~}{ll}{, jj}" format.name$ 't :=    % first name first
       "{\sc " t * "}" * 't := 	% put in small caps for LSA	
       dup #0 =
         'skip$
         { lsanewflag 
		     { "\lsadashifynew{" t * "}" * 't :=}
		     { "\lsadashify{" t * "}" * 't :=}
           if$
           dup #1 - 'dup :=}
       if$
       namesleft #1 >
          { ", " * t * }
%          { numnames #2 >
          { numnames #1 >
	         { "," * }
	         'skip$
	     if$
	     t "others" =
	        { " {\em et~al.\/}" * }
	        { "  \lsaand " * t * }
	     if$
	   }
       if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.norev.names}  % format names without reversing first in list
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{ff~}{vv~}{ll}{, jj}" format.name$ 't :=    % first name first
      nameptr #1 >
	{ namesleft #1 >
	    { ", " * t * }
	    { numnames #2 >
		{ "," * }
		'skip$
	      if$
	      t "others" =
		{ " {\em et~al.\/}" * }
		{ " \lsaand " * t * }
	      if$
	    }
	  if$
	}
	't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.rev.authors}
{ author empty$
    { "" }
    { author format.rev.names }
  if$
}

FUNCTION {format.key}			% this function is just for apalike
{ empty$
    { key field.or.null }
    { "" }
  if$
}

FUNCTION {format.rev.editors}
{ editor empty$
    { "" }
    { editor format.rev.names
      editor num.names$ #1 >
	{ " (eds.)"  *}
	{ " (ed.)"  * after.address 'output.state := }
      if$
    }
  if$
}

FUNCTION {format.norev.editors}
{ editor empty$
    { "" }
    { editor format.norev.names
      editor num.names$ #1 >
	{ ", editors" * }
	{ ", editor" * }
      if$
    }
  if$
}

FUNCTION {format.title}
{ title empty$
    { "" }
    { title "t" change.case$ }
  if$
}

FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
	{ t #1 #2 substring$ "--" = not
	    { "--" *
	      t #2 global.max$ substring$ 't :=
	    }
	    {   { t #1 #1 substring$ "-" = }
		{ "-" *
		  t #2 global.max$ substring$ 't :=
		}
	      while$
	    }
	  if$
	}
	{ t #1 #1 substring$ *
	  t #2 global.max$ substring$ 't :=
	}
      if$
    }
  while$
}

FUNCTION {format.btitle}
{ title empty$
    { "" }
%    { title "t" change.case$ emphasize}  % Put this line back to get true LSA format
    { title emphasize}
  if$
}

FUNCTION {format.school}
{ school empty$
  { "" }
  { school " dissertation" * }
 if$
}

FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { " " }
  if$
  swap$ * *
}

FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}

FUNCTION {format.bvolume}
{ volume empty$
    { "" }
    { "volume" volume tie.or.space.connect
      series empty$
	'skip$
	{ " of " * series emphasize * }
      if$
      "volume and number" number either.or.check
    }
  if$
}

FUNCTION {format.number.series}
{ volume empty$
    { number empty$
	{ series field.or.null }
	{ output.state mid.sentence =
	    { "number" }
	    { "Number" }
	  if$
	  number tie.or.space.connect
	  series empty$
	    { "there's a number but no series in " cite$ * warning$ }
	    { " in " * series * }
	  if$
	}
      if$
    }
    { "" }
  if$
}

FUNCTION {format.edition}
{ edition empty$
    { "" }
    { output.state mid.sentence =
	{ edition "l" change.case$ " edition" * }
	{ edition "t" change.case$ " edition" * }
      if$
    }
  if$
}

INTEGERS { multiresult }

FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
	{ #1 'multiresult := }
	{ t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}

FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages multi.page.check
	{ pages n.dashify }
	{ "p." pages tie.or.space.connect }
      if$
    }
  if$
}


FUNCTION {format.vol.num.pages}
{ volume field.or.null
%  number empty$
%    'skip$
%    { "(" number * ")" * *
%      volume empty$
%	{ "there's a number but no volume in " cite$ * warning$ }
%	'skip$
%      if$
%    }
%  if$
  pages empty$
    'skip$
    { duplicate$ empty$
	{ pop$ format.pages }
	{ "." * pages n.dashify * }
      if$
    }
  if$
}

FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
	{ "chapter" }
	{ type "l" change.case$ }
      if$
      chapter tie.or.space.connect
      pages empty$
	'skip$
	{ ", " * format.pages * }
      if$
    }
  if$
}

FUNCTION {format.in.ed.booktitle}
{ booktitle empty$
    { "" }
    { editor empty$
% Put back the following two lines to get true LSA
%	{ "In " booktitle "t" change.case$ emphasize * }
%	{ "In " booktitle "t" change.case$ emphasize * ", ed. by " * editor format.norev.names * }
	{ "In " booktitle emphasize * }
	{ "In " booktitle emphasize * ", ed. by " * editor format.norev.names * }
      if$
    }
  if$
}

FUNCTION {format.in.ed.proctitle}
{ booktitle empty$
    { "" }
    { editor empty$
	{ "In " booktitle emphasize * }
	{ "In " booktitle emphasize * ", ed. by " * editor format.norev.names * }
      if$
    }
  if$
}

FUNCTION {format.thesis.type}
{ type empty$
    'skip$
    { pop$
      type "t" change.case$
    }
  if$
}

FUNCTION {format.tr.number}
{ type empty$
    { "Technical Report" }
    'type
  if$
  number empty$
    { "t" change.case$ }
    { number tie.or.space.connect }
  if$
}

FUNCTION {format.article.crossref}
{ "In"							% this is for apalike
  " \cite{" * crossref * "}" *
}

FUNCTION {format.book.crossref}
{ volume empty$
    { "empty volume in " cite$ * "'s crossref of " * crossref * warning$
      "In "
    }
    { "Volume" volume tie.or.space.connect
      " of " *
    }
  if$
  "\cite{" * crossref * "}" *				% this is for apalike
}

FUNCTION {format.incoll.inproc.crossref}
{ "In"							% this is for apalike
  " \cite{" * crossref * "}" *
}

FUNCTION {article}
{ output.bibitem
  format.rev.authors "author" output.check
  new.block
  author format.key output				% special for apa/lsa
  output.year.check					% special for lsa
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
%    { journal emphasize "journal" output.check
%      " " * format.vol.num.pages * output
%    }
    { journal empty$
        { "empty journal in " cite$ * warning$ format.vol.num.pages output}
        { journal emphasize " " * format.vol.num.pages * output }
      if$
    }
    { format.article.crossref output.nonnull
      format.pages output
    }
  if$
  new.block
  note output
  fin.entry
}



FUNCTION {book}
{ output.bibitem
  author empty$
    { format.rev.editors "author and editor" output.check 
      editor format.key output
    }
    { format.rev.authors output.nonnull
      crossref missing$
	{ "author and editor" editor either.or.check }
	'skip$
      if$
    }
  if$
  new.block
  output.year.check					% special for lsa
  new.block
  format.btitle "title" output.check
  crossref missing$
    { format.bvolume output
      new.block
      format.number.series output
      new.sentence
      format.address
      publisher "publisher" output.check
    }
    { new.block
      format.book.crossref output.nonnull
    }
  if$
  format.edition output
  new.block
  note output
  fin.entry
}

FUNCTION {booklet}
{ output.bibitem
  format.rev.authors output
  author format.key output				% special for apa/lsa
  new.block						%
  output.year.check					%
  new.block
  format.title "title" output.check
  new.block
  howpublished output
  address output
  new.block
  note output
  fin.entry
}

FUNCTION {inbook}
{ output.bibitem
  author empty$
    { format.rev.editors "author and editor" output.check
      editor format.key output
    }
    { format.rev.authors output.nonnull
      crossref missing$
	{ "author and editor" editor either.or.check }
	'skip$
      if$
    }
  if$
  new.block
  output.year.check					% special for lsa
  new.block
  format.btitle "title" output.check
  crossref missing$
    { format.bvolume output
      format.chapter.pages "chapter and pages" output.check
      new.block
      format.number.series output
      new.sentence
      format.address
      publisher "publisher" output.check
    }
    { format.chapter.pages "chapter and pages" output.check
      new.block
      format.book.crossref output.nonnull
    }
  if$
  format.edition output
  new.block
  note output
  fin.entry
}

FUNCTION {incollection}
{ output.bibitem
  format.rev.authors "author" output.check
  new.block
  author format.key output				% special for
  output.year.check					% lsa
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
    { format.in.ed.booktitle "booktitle" output.check
      format.bvolume output
      format.number.series output
      format.chapter.pages output
      new.sentence
      format.address
      publisher "publisher" output.check
      format.edition output
    }
    { format.incoll.inproc.crossref output.nonnull
      format.chapter.pages output
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {inproceedings}
{ output.bibitem
  format.rev.authors "author" output.check
  new.block
  author format.key output				% special for
  output.year.check					% lsa
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
    { format.in.ed.proctitle "booktitle" output.check
      format.bvolume output
      format.number.series output
      format.pages output
      address output					% for apalike
      new.sentence					% there's no year
      organization output				% here so things
      publisher output					% are simpler
    }
    { format.incoll.inproc.crossref output.nonnull
      format.pages output
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {conference} { inproceedings }

FUNCTION {manual}
{ output.bibitem
  format.rev.authors output
  author format.key output				% special for
  output.year.check					% lsa
  new.block
  format.btitle "title" output.check
  organization address new.block.checkb
  organization output
  address output
  format.edition output
  new.block
  note output
  fin.entry
}

FUNCTION {mastersthesis}
{ output.bibitem
  format.rev.authors "author" output.check
  author format.key output				% special for
  output.year.check					% lsa
  new.block
  format.title "title" output.check
  new.block
  "Master's thesis" format.thesis.type output.nonnull
  school "school" output.check
  address output
  new.block
  note output
  fin.entry
}

FUNCTION {misc}
{ output.bibitem
  format.rev.authors output
  author format.key output				% special for
  output.year.check					% lsa
  new.block
  format.title output
  new.block
  howpublished output
  new.block
  note output
  fin.entry
}

FUNCTION {phdthesis}
{ output.bibitem
  format.rev.authors "author" output.check
  author format.key output				% special for
  output.year.check					% lsa
  new.block
  format.btitle "title" output.check
  new.block
  format.address
  format.school "school" output.check
  new.block
  note output
  fin.entry
}

FUNCTION {proceedings}
{ output.bibitem
  format.rev.editors output
  editor format.key output				% special for
  new.block
  output.year.check					% special for lsa
  new.block
  format.btitle "title" output.check
  format.bvolume output
  format.number.series output
  address output				% for apalike
  new.sentence					% we always output
  organization output				% a nonempty organization
  publisher output				% here
  new.block
  note output
  fin.entry
}

FUNCTION {techreport}
{ output.bibitem
  format.rev.authors "author" output.check
  author format.key output				% special for lsa/apa
  new.block
  output.year.check					% special for lsa
  new.block
  format.title "title" output.check
  new.block
  format.tr.number output.nonnull
  institution "institution" output.check
  address output
  new.block
  note output
  fin.entry
}

FUNCTION {unpublished}
{ output.bibitem
  format.rev.authors "author" output.check
  author format.key output				% special for
  output.year.check					% lsa
  new.block
  format.title "title" output.check
  new.block
  note "note" output.check
  fin.entry
}

FUNCTION {default.type} { misc }

MACRO {jan} {"January"}

MACRO {feb} {"February"}

MACRO {mar} {"March"}

MACRO {apr} {"April"}

MACRO {may} {"May"}

MACRO {jun} {"June"}

MACRO {jul} {"July"}

MACRO {aug} {"August"}

MACRO {sep} {"September"}

MACRO {oct} {"October"}

MACRO {nov} {"November"}

MACRO {dec} {"December"}

MACRO {acmcs} {"ACM Computing Surveys"}

MACRO {acta} {"Acta Informatica"}

MACRO {cacm} {"Communications of the ACM"}

MACRO {ibmjrd} {"IBM Journal of Research and Development"}

MACRO {ibmsj} {"IBM Systems Journal"}

MACRO {ieeese} {"IEEE Transactions on Software Engineering"}

MACRO {ieeetc} {"IEEE Transactions on Computers"}

MACRO {ieeetcad}
 {"IEEE Transactions on Computer-Aided Design of Integrated Circuits"}

MACRO {ipl} {"Information Processing Letters"}

MACRO {jacm} {"Journal of the ACM"}

MACRO {jcss} {"Journal of Computer and System Sciences"}

MACRO {scp} {"Science of Computer Programming"}

MACRO {sicomp} {"SIAM Journal on Computing"}

MACRO {tocs} {"ACM Transactions on Computer Systems"}

MACRO {tods} {"ACM Transactions on Database Systems"}

MACRO {tog} {"ACM Transactions on Graphics"}

MACRO {toms} {"ACM Transactions on Mathematical Software"}

MACRO {toois} {"ACM Transactions on Office Information Systems"}

MACRO {toplas} {"ACM Transactions on Programming Languages and Systems"}

MACRO {tcs} {"Theoretical Computer Science"}


READ

FUNCTION {sortify}
{ purify$
  "l" change.case$
}

INTEGERS { len }

FUNCTION {chop.word}
{ 's :=
  'len :=
  s #1 len substring$ =
    { s len #1 + global.max$ substring$ }
    's
  if$
}

%			There are three apalike cases: one person (Jones),
%			two (Jones and de~Bruijn), and more (Jones et~al.).
%			This function is much like format.crossref.editors.
%
FUNCTION {format.lab.names}
{ 's :=
  s #1 "{vv~}{ll}" format.name$
  s num.names$ duplicate$
  #2 >
    { pop$ " {\em et~al.\/}" * }
    { #2 <
	'skip$
	{ s #2 "{ff }{vv }{ll}{ jj}" format.name$ "others" =
	    { " {\em et~al.\/}" * }
	    { " \lsaand " * s #2 "{vv~}{ll}" format.name$ * }
	  if$
	}
      if$
    }
  if$
}

FUNCTION {author.key.label}
{ author empty$
    { key empty$
	{ cite$ #1 #3 substring$ }
	'key					% apalike uses the whole key
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {author.editor.key.label}
{ author empty$
    { editor empty$
	{ key empty$
	    { cite$ #1 #3 substring$ }
	    'key				% apalike uses the whole key
	  if$
	}
	{ editor format.lab.names }
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {editor.key.label}
{ editor empty$
    { key empty$
	{ cite$ #1 #3 substring$ }
	'key			% apalike uses the whole key, no organization
      if$
    }
    { editor format.lab.names }
  if$
}

FUNCTION {calc.label}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.key.label
    { type$ "proceedings" =
	'editor.key.label			% lsa/apa ignores organization
	'author.key.label			% for labeling and sorting
      if$
    }
  if$
  duplicate$

  "\protect\citeauthoryear{" swap$ * "}{" *
  year field.or.null * % #-1 #4 substring$	*	% uses all four digits
  'label :=

  year field.or.null * % #-1 #4 substring$ *	% uses all four digits
  sortify 'sort.label :=
}

FUNCTION {sort.format.names}
{ 's :=
  #1 'nameptr :=
  ""
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 >
	{ "   " * }
	'skip$
      if$						% apalike uses initials
      s nameptr "{vv{ } }{ll{ }}{  ff{ }}{  jj{ }}" format.name$ 't := % <= here
      nameptr numnames = t "others" = and
	{ "et al" * }
	{ t sortify * }
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {sort.format.title}
{ 't :=
  "A " #2
    "An " #3
      "The " #4 t chop.word
    chop.word
  chop.word
  sortify
  #1 global.max$ substring$
}

FUNCTION {author.sort}
{ author empty$
    { key empty$
	{ "to sort, need author or key in " cite$ * warning$
	  ""
	}
	{ key sortify }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {author.editor.sort}
{ author empty$
    { editor empty$
	{ key empty$
	    { "to sort, need author, editor, or key in " cite$ * warning$
	      ""
	    }
	    { key sortify }
	  if$
	}
	{ editor sort.format.names }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {editor.sort}
{ editor empty$
    { key empty$
	{ "to sort, need editor or key in " cite$ * warning$
	  ""
	}
	{ key sortify }
      if$
    }
    { editor sort.format.names}
  if$
}

%			apalike uses two sorting passes; the first one sets the
%			labels so that the `a's, `b's, etc. can be computed;
%			the second pass puts the references in "correct" order.
%			The presort function is for the first pass. It computes
%			label, sort.label, and title, and then concatenates.
FUNCTION {presort}
{ calc.label
  label sortify
  "    "
  *
  type$ "book" =
  type$ "inbook" =
  or
    'author.editor.sort
    { type$ "proceedings" =
	'editor.sort
	'author.sort
      if$
    }
  if$
  #1 entry.max$ substring$	% for
  'sort.label :=		% apalike
  sort.label			% style
  *
  "    "
  *
  title field.or.null
  sort.format.title
  *
  #1 entry.max$ substring$
  'sort.key$ :=
}

ITERATE {presort}

SORT		% by label, sort.label, title---for final label calculation

STRINGS { last.label next.extra }	% apalike labels are only for the text;

INTEGERS { last.extra.num }		% there are none in the bibliography

FUNCTION {initialize.extra.label.stuff}	% and hence there is no `longest.label'
{ #0 int.to.chr$ 'last.label :=
  "" 'next.extra :=
  #0 'last.extra.num :=
}

FUNCTION {forward.pass}
{ last.label label =
    { last.extra.num #1 + 'last.extra.num :=
      last.extra.num int.to.chr$ 'extra.label :=
    }
    { "a" chr.to.int$ 'last.extra.num :=
      "" 'extra.label :=
      label 'last.label :=
    }
  if$
}
FUNCTION {reverse.pass}
{ next.extra "b" =
    { "a" 'extra.label := }
    'skip$
  if$
  label extra.label * "}" * 'label :=   % CHANGED - pfps 15 Feb 1989
  extra.label 'next.extra :=
}


%FUNCTION {reverse.pass}
%{ next.extra "b" =
%    { "a" 'extra.label := }
%    'skip$
%  if$
%  label extra.label * 'label :=
%  extra.label 'next.extra :=
%}

EXECUTE {initialize.extra.label.stuff}

ITERATE {forward.pass}

REVERSE {reverse.pass}

%				Now that the label is right we sort for real,
%				on sort.label then year then title.  This is
%				for the second sorting pass.
FUNCTION {bib.sort.order}
{ sort.label
  "    "
  *
  year field.or.null sortify
  *
  "    "
  *
  title field.or.null
  sort.format.title
  *
  #1 entry.max$ substring$
  'sort.key$ :=
}

ITERATE {bib.sort.order}

SORT		% by sort.label, year, title---giving final bibliography order

FUNCTION {begin.bib}
{ preamble$ empty$				% no \etalchar in apalike
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\begin{thebibliography}{}" write$ newline$		% no labels in apalike
}

% LSA style replaces all entries which repeat an initial string of authors of the previous entry 
% with a long dash.  We do the same by iterating over entries, setting a counter for repeats,
% which says how many names were repeated,  and then when outputing editors or authors
% we replace that many names by dashes
%
FUNCTION {init.dup.names}
{
    "NOOP" 'start.author :=
    "NOOP" 'last.author :=
    "NOOP" 'last.single.author :=
     #0 'last.num :=
     #0 'start.num :=
}


FUNCTION {is.substring} % pops two strings, returns 1 if top is a substring of next (not top), else 0
{
	'x :=
	'y :=  
	x text.length$  y text.length$ >
		% Y is less
		{ #0}
		% X is less or equal , see if Y's initial substring = x
		{   y #1 x text.length$ substring$  x =
		 { #1}
		 { #0}
		 if$
		}
			
	if$
}

FUNCTION {format.norev.names.nocommas}  
% format names without reversing first in list, 
% Used here only to build a string to compare with the previous entry for a substring match
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{ff~}{vv~}{ll}{, jj}" format.name$ 't :=    % first name first
      nameptr #1 >
	{ t * }
	't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {check.dup.names}
%  First check if the previous entry is a substring of this one (or equal).
% if so, use that to set the number of dashes.  If not, see if the first
% entry of this series is a substring of the current entry.  If not, try
% just the first author of the last entry.  This last check is non-LSA standard.
{
    author missing$
	{ editor missing$
		'skip$
		{ editor  format.norev.names.nocommas last.author is.substring
		    { last.num 'dup :=}
		    { editor  format.norev.names.nocommas start.author is.substring 
			{ start.num 'dup := 
			  editor num.names$ 'last.num := 
			  editor  format.norev.names.nocommas 'last.author :=  }
			{ editor #1 "{vv~}{ll}{, jj}{, ff}" format.name$ last.single.author =
			   { #1 'dup :=
			     #1 'lsanewflag :=
			     editor num.names$ 'last.num := 
			     editor  format.norev.names.nocommas 'last.author :=  }
			   { editor #1 "{vv~}{ll}{, jj}{, ff}" format.name$ 'last.single.author := 
			     editor  format.norev.names.nocommas 'start.author :=  
			     editor num.names$ 'start.num := 
			     #0 'dup := }
			   if$
			}
			if$
		    }
		 if$
		}
	  if$
	}
	{ author  format.norev.names.nocommas last.author is.substring
	    { last.num 'dup :=}
	    { author  format.norev.names.nocommas start.author is.substring 
		{ start.num 'dup := 
		  author num.names$ 'last.num := 
		  author  format.norev.names.nocommas 'last.author :=  }
		{ author #1 "{vv~}{ll}{, jj}{, ff}" format.name$ last.single.author =
		   { #1 'dup :=
			 #1 'lsanewflag :=
		     author num.names$ 'last.num := 
		     author  format.norev.names.nocommas 'last.author :=  }
		   { author #1 "{vv~}{ll}{, jj}{, ff}" format.name$ 'last.single.author := 
		     author  format.norev.names.nocommas 'start.author :=  
		     author num.names$ 'start.num := 
		     #0 'dup := }
		   if$
		}
		if$
	    }
	 if$
	}
    if$
}



EXECUTE {init.dup.names}

ITERATE {check.dup.names}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

ITERATE {call.type$}

FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {end.bib}
