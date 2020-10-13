"
parses a stream of HtmlToken's into an HtmlDocument.  All token become an entity of some sort in the resulting document; some things are left only as comments, though.
"
Class {
	#name : #HtmlParser,
	#superclass : #Object,
	#category : #'Etoys-Squeakland-Network-HTML-Parser'
}

{ #category : #example }
HtmlParser class >> example1 [
	"HtmlParser example1"
	| input |
	input := ReadStream on: 
'<html>
<head>
<title>The Gate of Chaos</title>
</head>

<body>

<h1>Chaos</h1>



<h2>Into the Maelstrom</h2>
Direction is useless in the ever-changing Maelstrom.  However,
if you wander with purpose, you might be able to find....
<ul>
<li><a href="/cgi-bin/w">see who''s logged in</a>
<li><a href="/Telnet/connect.html">log in, if you (oooh) have an account</a>
<li><a href="http://chaos.resnet.gatech.edu:9000/sw">The Chaos Swiki</a>--scribble on chaos
<li>the original <a href="/cgi-bin/guestlog-print">Visitor Sands</a>
<li>my old <a href="rant.html">Rant Page</a>
<li>neverending <a href="/cgi-bin/bread">poll</a>: do you have an opinion on bread?
<li>a <a href="http://www.cc.gatech.edu/~lex/linux.html">Linux page</a>-- free UNIX for PC''s!
<li><a href="english.au">Hear Linus Himself speak!!</a>
<li><a href="/doc/">some docs on all kinds of computer stuff</a>
</ul>

<hr>


<h2>Paths of Retreat</h2>
Several commonly travelled ways have left paths leading 
<em>away</em> from the maelstrom, too:
<p>
<ul>
<li><a href="friends.html">Friends of Chaos</a>
<li><a href="http://www.apache.org/">The <em>Apache</em> home page</a> -- 
        <em>Chaos</em>''s WWW server!
<li><a href="http://www.ee.umanitoba.ca/~djc/personal/notscape.html">
Notscape</a>

the <a href="http://www.eskimo.com/%7Eirving/anti-ns/">Anti-Netscape
Page</a> -- fight the tyranny!
</ul>

<hr>
<a href="/analog/usage.html">usage stats</a> for this server

<hr>
<a href="http://www.eff.org/blueribbon.html"><img src="blueribbon.gif" alt="[blue ribbon campaign]"></a>
<a href="http://www.ee.umanitoba.ca/~djc/personal/notscape.html">
<img src="notscape.gif" alt="[NOTscape]">
</a>
<a href="http://www.anybrowser.org/campaign/">
<img src="anybrowser3.gif" alt="[Best Viewed With Any Browser]"></a>
</body>
</html>'.

	^HtmlParser parse: input
]

{ #category : #parsing }
HtmlParser class >> parse: aStream [
	^self parseTokens: (HtmlTokenizer on: aStream)

]

{ #category : #parsing }
HtmlParser class >> parseTokens: tokenStream [
	|  entityStack document head token matchesAnything entity body |

	entityStack := OrderedCollection new.

	"set up initial stack"
	document := HtmlDocument new.
	entityStack add: document.
	
	head := HtmlHead new.
	document addEntity: head.
	entityStack add: head.


	"go through the tokens, one by one"
	[ token := tokenStream next.  token = nil ] whileFalse: [
		(token isTag and: [ token isNegated ]) ifTrue: [
			"a negated token"
			(token name ~= 'html' and: [ token name ~= 'body' ]) ifTrue: [
				"see if it matches anything in the stack"
				matchesAnything := (entityStack detect: [ :e | e tagName = token name ] ifNone: [ nil ]) isNil not.
				matchesAnything ifTrue: [
					"pop the stack until we find the right one"
					[ entityStack last tagName ~= token name ] whileTrue: [ entityStack removeLast ].
					entityStack removeLast.
				]. ] ]
		ifFalse: [
			"not a negated token.  it makes its own entity"
			token isComment ifTrue: [
				entity := HtmlCommentEntity new initializeWithText: token source.
			].
			token isText ifTrue: [
				entity := HtmlTextEntity new text: token text.
				(((entityStack last shouldContain: entity) not) and: 
					[ token source isAllSeparators ]) ifTrue: [
					"blank text may never cause the stack to back up"
					entity := HtmlCommentEntity new initializeWithText: token source ].
			].
			token isTag ifTrue: [
				entity := token entityFor.
				entity = nil ifTrue: [ entity := HtmlCommentEntity new initializeWithText: token source ] ].
			(token name = 'body')
				ifTrue: [body ifNotNil: [document removeEntity: body].
					body := HtmlBody new initialize: token.
					document addEntity: body.
					entityStack add: body].

			entity = nil ifTrue: [ self error: 'could not deal with this token' ].

			entity isComment ifTrue: [
				"just stick it anywhere"
				entityStack last addEntity: entity ]
			ifFalse: [
				"only put it in something that is valid"
				[ entityStack last mayContain: entity ] 
					whileFalse: [ entityStack removeLast ].

				"if we have left the head, create a body"					
				(entityStack size < 2 and: [body isNil]) ifTrue: [
					body := HtmlBody new.
					document addEntity: body.
					entityStack add: body  ].

				"add the entity"
				entityStack last addEntity: entity.
				entityStack addLast: entity.
			].
		]].

	body == nil ifTrue: [
		"add an empty body"
		body := HtmlBody new.
		document addEntity: body ].

	document parsingFinished.

	^document
]
