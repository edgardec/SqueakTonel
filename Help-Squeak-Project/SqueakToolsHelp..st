Class {
	#name : #SqueakToolsHelp,
	#superclass : #SqueakHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #pages }
SqueakToolsHelp class >> basicDevelopmentTools [
	"This method was automatically generated. Edit it using:"
	"SqueakToolsHelp edit: #basicDevelopmentTools"
	^(HelpTopic
		title: 'Basic Development Tools'
		contents: 
'Smalltalk environments have some of the best user interfaces for programmers ever devised. Those who have programmed in Lisp under Emacs have some idea, but Smalltalk is even better.
		
You should learn these basic tools thoroughly:
- Workspace
- Transcript (do it: Transcript showln: ''Hello Squeak!!'')
- Browser
- Inspector
- File List
- Change Sorter (and also the Dual Change Sorter)
- Debugger
- Method Finder	
!
]style[(235 9 3 10 9 34 4 7 3 9 3 9 3 13 15 18 4 8 3 14 1),Rcode://Workspace open;,,Rcode://Transcript open;,,Rcode://Transcript showln: ''Hello Squeak!!'';,,Rcode://Browser open;,,Rcode://#(S Q U E A K) inspect;,,Rcode://FileList open;,,Rcode://ChangeSorter new open;,,Rcode://DualChangeSorter new open;,,Rcode://7/0;,,Rcode://SelectorBrowser new open;,!' readStream nextChunkText)
			key: #basicDevelopmentTools
]

{ #category : #accessing }
SqueakToolsHelp class >> bookName [ 
	^'Tools'
]

{ #category : #pages }
SqueakToolsHelp class >> fontSizeSummary [
	^HelpTopic 
		title: 'Font Size Summary'
		readOnlyContents: TextStyle fontSizeSummaryContents
]

{ #category : #accessing }
SqueakToolsHelp class >> pages [
	^#(basicDevelopmentTools fontSizeSummary)
]
