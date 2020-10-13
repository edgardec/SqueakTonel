Class {
	#name : #HelpHowToHelpTopics,
	#superclass : #HelpOnHelp,
	#category : #'HelpSystem-Core-Help'
}

{ #category : #accessing }
HelpHowToHelpTopics class >> bookName [
	^'Implementation'
]

{ #category : #pages }
HelpHowToHelpTopics class >> overview [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopics edit: #overview"
	^HelpTopic
		title: 'Overview'
		contents: 
'THE IMPLEMENTATION

The help system typically consists of help books including one or more pages. A book or page is therefore a "topic of interest"  providing contents for help to a user. A topic has a title and an icon and is able to have subtopics forming a hierarchy of topics. This simple model is reflected in the class HelpTopic.

Since this model forms a hierarchical structure of help topics there is a browser with a tree to display the help contents. This browser is implemented in class HelpBrowser.

You can open this browser programmatically using:

   HelpBrowser open

(or simply click on that line above)
The HelpBrowser is also available from the main menubar at the top of the Squeak screen
!
]style[(566 16 127),dHelpBrowser open;;,!' readStream nextChunkText
]

{ #category : #pages }
HelpHowToHelpTopics class >> page1 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopics edit: #page1"
	^HelpTopic
		title: '1. Simple help topics'
		contents: 
'The help browser usually operates on a hierarchy of help topics with one help topic at the root level. Evaluate the following expression in a workspace to contruct a simple help topic and open it as a root topic in the help browser, or simply click on the underlined text below
		
		|root|
		root := HelpTopic 
			title: ''My first topic''
			contents: ''A simple topic of interest''.					
		
		HelpBrowser openOn: root
		
		
Note that the help browser displays the contents of our topic in the right page and uses the topics title as the title for the help browser window.	
		!
]style[(283 132 158),d|root|
		root := HelpTopic 
			title: ''My first topic''
			contents: ''A simple topic of interest''.					
		
		HelpBrowser openOn: root;;,!' readStream nextChunkText
]

{ #category : #pages }
HelpHowToHelpTopics class >> page2 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopics edit: #page2"
	^HelpTopic
		title: '2. Forming a hierarchy'
		contents: 
'To form a hierarchy we just have to add new subtopics on our root topic.
Evaluate the following expression in a workspace to contruct a simple help topic and open it as a root topic in the help browser, or simply click on the underlined text below
		
		|root sub1 sub2|
		root := HelpTopic 
			title: ''My first topic''
			contents: ''A simple topic of interest''.		
		sub1 := HelpTopic 
			title: ''My first subtopic''
			contents: ''First subsection''.		
		sub2 := HelpTopic 
			title: ''My second subtopic''
			contents: ''Second subsection''.		
		root 
			addSubtopic: sub1; 
			addSubtopic: sub2.
		HelpBrowser openOn: root
		
		!
]style[(253 363 6),d|root sub1 sub2|
		root := HelpTopic 
			title: ''My first topic''
			contents: ''A simple topic of interest''.		
		sub1 := HelpTopic 
			title: ''My first subtopic''
			contents: ''First subsection''.		
		sub2 := HelpTopic 
			title: ''My second subtopic''
			contents: ''Second subsection''.		
		root 
			addSubtopic: sub1; 
			addSubtopic: sub2.
		HelpBrowser openOn: root;;,!' readStream nextChunkText
]

{ #category : #pages }
HelpHowToHelpTopics class >> page3 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopics edit: #page3"
	^HelpTopic
		title: '3. Adding icons'
		contents: 
'If you dont like the default icon you can add own custom icons to the topics. See the class HelpIcons for more details.
Note how the icon is added to the ''sub2'' section from the previous example.

Evaluate the following expression in a workspace to contruct a simple help topic and open it as a root topic in the help browser, or simply click on the underlined text below
		
		|root sub1 sub2|
		root := HelpTopic 
			title: ''My first topic''
			contents: ''A simple topic of interest''.		
		sub1 := HelpTopic 
			title: ''My first subtopic''
			contents: ''First subsection''.		
		sub2 := HelpTopic 		     
			title: ''My second subtopic''
			 icon: (HelpIcons iconNamed: #packageIcon)
			contents: ''Second subsection''.		
		root 
			addSubtopic: sub1; 
			addSubtopic: sub2.
		HelpBrowser openOn: root
		
		!
]style[(377 416 6),d|root sub1 sub2|
		root := HelpTopic 
			title: ''My first topic''
			contents: ''A simple topic of interest''.		
		sub1 := HelpTopic 
			title: ''My first subtopic''
			contents: ''First subsection''.		
		sub2 := HelpTopic 		     
			title: ''My second subtopic''
			 icon: (HelpIcons iconNamed: #packageIcon)
			contents: ''Second subsection''.		
		root 
			addSubtopic: sub1; 
			addSubtopic: sub2.
		HelpBrowser openOn: root;;,!' readStream nextChunkText
]

{ #category : #pages }
HelpHowToHelpTopics class >> page4 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopics edit: #page4"
	^HelpTopic
		title: '4. Your own help objects'
		contents: 
'You can open this help browser directly on an instance of HelpTopic, but it is more common to open it on any object that understands the message #asHelpTopic.

So you can write for instance:

   HelpBrowser openOn: Integer

opening a short API help/system reference on the Integer class.
The above expression is the short form for:

   HelpBrowser openOn: (SystemReference forClass: Integer)

If you want you can include the subclasses:

   HelpBrowser openOn: (SystemReference hierarchyFor: Integer)

or even methods

   HelpBrowser openOn: (SystemReference hierarchyWithMethodsFor: Integer)

You can browse the whole system reference documentation using:

    HelpBrowser openOn: SystemReference

But these are only a few examples what we can extract from the 
system. 

However - the major goal for this is NOT an API browser as the typical method comments are not generally suited to making an automatic API document. The idea is to provide a simple architecture to produce browsable help contents depending on the context. For instance it should also be possible to use the help system to provide end user help on any commercial application that is written with the Smalltalk system.


!
]style[(195 27 114 55 50 59 22 70 70 35 494),dHelpBrowser openOn: Integer;;,,dHelpBrowser openOn: (SystemReference forClass: Integer);;,,dHelpBrowser openOn: (SystemReference hierarchyFor: Integer);;,,dHelpBrowser openOn: (SystemReference hierarchyWithMethodsFor: Integer);;,,dHelpBrowser openOn: SystemReference;;,!' readStream nextChunkText
]

{ #category : #pages }
HelpHowToHelpTopics class >> page5 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopics edit: #page5"
	^HelpTopic
		title: '5. Help sources'
		contents: 
'Since the underlying model is very simple you can easily fill it with nearly any information from different sources. Try this:

|topic day url sub|
topic := HelpTopic named: ''Last week on Squeak IRC''.
0 to: 7 do: [:index |
	day := (Date today subtractDays: index) printFormat: #(3 2 1 $. 1 2 2).
	url := ''http://tunes.org/~nef/logs/squeak/'' , day.
	sub := HelpTopic 
			title: day contents: (HTTPLoader default retrieveContentsFor: url) contents.
	topic addSubtopic: sub.
].
HelpBrowser openOn: topic

 
 

!
]style[(128 372 7),d|topic day url sub|
topic := HelpTopic named: ''Last week on Squeak IRC''.
0 to: 7 do: [:index |
	day := (Date today subtractDays: index) printFormat: #(3 2 1 $. 1 2 2).
	url := ''http://tunes.org/~nef/logs/squeak/'' , day.
	sub := HelpTopic 
			title: day contents: (HTTPLoader default retrieveContentsFor: url) contents.
	topic addSubtopic: sub.
].
HelpBrowser openOn: topic;;,!' readStream nextChunkText
]

{ #category : #accessing }
HelpHowToHelpTopics class >> pages [
	^#(overview page1 page2 page3 page4 page5)
]
