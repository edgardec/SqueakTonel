Class {
	#name : #ToolIconHelp,
	#superclass : #Object,
	#classVars : [
		'HelpTexts'
	],
	#category : #'Tools-Base'
}

{ #category : #icons }
ToolIconHelp class >> abstract [

	^ 'This method is abstract.' 
]

{ #category : #icons }
ToolIconHelp class >> arrowDown [

	^ 'This method is overriden by another method.'
]

{ #category : #icons }
ToolIconHelp class >> arrowUp [

	^ 'This method overrides a super method.'
]

{ #category : #icons }
ToolIconHelp class >> arrowUpAndDown [

	^ 'This method overrides and is overridden by other methods.'
]

{ #category : #icons }
ToolIconHelp class >> blank [

	^ ''
]

{ #category : #icons }
ToolIconHelp class >> breakpoint [ 

	^ 'This method contains a breakpoint.'
]

{ #category : #icons }
ToolIconHelp class >> flag [

	^ 'This method needs attention of some kind.' 
]

{ #category : #accessing }
ToolIconHelp class >> helpTexts [

	^ HelpTexts ifNil: [HelpTexts := IdentityDictionary new]
]

{ #category : #'icons help' }
ToolIconHelp class >> iconHelpNamed: aSymbol [

	^ (self respondsTo: aSymbol)
		ifTrue: [self helpTexts at: aSymbol ifAbsentPut: [self perform: aSymbol]]
		ifFalse: [String empty]
	
]

{ #category : #icons }
ToolIconHelp class >> no [

	^  'This method should not be implemented.' 
]

{ #category : #icons }
ToolIconHelp class >> notOverridden [

	^ 'This method is abstract and has not been overridden.' 
]

{ #category : #icons }
ToolIconHelp class >> primitive [

	^ 'This method implements a primitive.'
]
