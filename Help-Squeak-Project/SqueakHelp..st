Class {
	#name : #SqueakHelp,
	#superclass : #CustomHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakHelp class >> bookName [ 
	^'Squeak'
]

{ #category : #accessing }
SqueakHelp class >> icon [
	(self name = #SqueakHelp) ifTrue: [^HelpIcons iconNamed: #squeakIcon].
	^nil
]

{ #category : #pages }
SqueakHelp class >> introduction [
	"This method was automatically generated. Edit it using:"
	"SqueakHelp edit: #introduction"
	^(HelpTopic
		title: 'Welcome'
		contents: 
'Welcome to Squeak

Visit http://www.squeak.org for the lastest information.

Squeak is an open-source Smalltalk programming system available for all major platforms. It features the Morphic framework, which promotes low effort graphical, interactive application development and maintenance. Many projects have been successfully created with Squeak in a wide range of domains such as education, multimedia, gaming, research, and commerce. Squeak is fast, flexible and free.

It''s Smalltalk!!
Everything is an object. Objects collaborate by sending messages to achieve the desired application behavior. The Smalltalk programming language has a concise syntax and simple execution semantics. The Smalltalk system is implemented in itself: Compiler, debugger, programming tools, and so on are all Smalltalk code the user can read and modify. Novice programmers can get started easily and experts can engineer elegant solutions at large.

Morphic UI Framework
All graphical objects are tangible and interactively changeable. This promotes short feedback loops and low-effort application development. Morphic thus leverages the live programming experience of traditional Smalltalk environments from a mainly text-focused domain to a graphical one.

Powerful Tooling
The dynamic Squeak environment provides a variety of tools for browsing, writing, executing, and versioning Smalltalk code. Multiple debugging sessions can be served concurrently. Thanks to Morphic, tool customization can be achieved with reasonable effort.

Fast Virtual Machine
There are several fast Squeak VMs that also support other languages of the Smalltalk family. Meta-tracing, just-in-time compilation, stack-to-register mapping, and aggressive in-line message caching yield efficiency in executing Smalltalk code.

Web Development
With frameworks like Seaside and AIDA, Squeak can be a web server. It provides a layered set of abstractions over HTTP and HTML that let you build highly interactive web applications quickly, reusably, and maintainably.

Multi-Platform Support
Squeak supports Windows, Linux (X86, X64 and ARM), and macOS and is preinstalled on C.H.I.P., Raspberry Pi, and OLPC XO.!
]style[(19 5 1 21 29 399 15 18 6 33 8 87 14 80 8 2 8 2 17 161 20 27 8 254 16 64 8 11 9 6 10 152 20 247 15 22 7 5 4 18 3 163 22 121)a0b,a0,a0b,Rhttp://www.squeak.org;,a0,,i,,Rcode://Object;,,Rcode://MessageSend;,,Rcode://HelpBrowser openOn: TerseGuideHelp;,,Rcode://Compiler;,,Rcode://Debugger;,,Rcode://Browser;,,i,,Rcode://Morph new openInHand;,,i,,Rcode://ToolSet browse: String selector: #findTokens:;,,Rcode://7/0;,,Rcode://MCWorkingCopyBrowser new show;,,i,,i,,Rhttp://www.seaside.st/;,,Rhttp://www.aidaweb.si/;,,Rcode://WebClient;,,i,!' readStream nextChunkText)
			key: #introduction;
			shouldStyle: false;
			yourself
]

{ #category : #accessing }
SqueakHelp class >> pages [
	^#(introduction SqueakProjectHelp SqueakToolsHelp SqueakTutorials)
]

{ #category : #accessing }
SqueakHelp class >> priority [

	^ self == SqueakHelp ifTrue: [-9999 "at the top"] ifFalse: [nil]
]
