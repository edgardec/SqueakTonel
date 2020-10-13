"
This class manages methods that include breakpoints.
It has several class methods to install and uninstall breakpoints.

Evaluating ""BreakpointManager clear"" will remove all installed breakpoints in the system.

Known issues:
- currently, only break-on-entry type of breakpoints are supported
- emphasis change not implemented for MVC browsers
- uninstalling the breakpoint doesn't auto-update other browsers
- uninstalling a breakpoint while debugging should restart-simulate the current method

Ernest Micklei, 2002

Send comments to emicklei@philemonworks.com
"
Class {
	#name : #BreakpointManager,
	#superclass : #Object,
	#classVars : [
		'Installed'
	],
	#category : #'System-Tools'
}

{ #category : #'intialization-release' }
BreakpointManager class >> clear [
	"BreakpointManager clear"

	self installed copy keysDo:[ :breakMethod |
		self unInstall: breakMethod].
		
		
]

{ #category : #private }
BreakpointManager class >> compilePrototype: aSymbol in: aClass [
	"Compile and answer a new method containing a break statement"

	| oldSource parser methodNode breakOnlyMethodNode sendBreakMessageNode hasTemps newSource mark positionParser markBeforePragmas pragmasFollowTemps |
	oldSource := aClass sourceCodeAt: aSymbol.
	parser := aClass newParser.
	methodNode := parser
						parse: oldSource
						class: aClass
						noPattern: false
						notifying: nil 
						ifFail: [self error: '[breakpoint] unable to install breakpoint'].
	breakOnlyMethodNode := aClass newCompiler
								compile: 'temporaryMethodSelectorForBreakpoint self break. ^self'
								in: aClass 
								notifying: nil 
								ifFail: [self error: '[breakpoint] unable to install breakpoint'].
	sendBreakMessageNode := breakOnlyMethodNode block statements first.
	methodNode block statements addFirst: sendBreakMessageNode.
	"Use anothe rparser to discover positions because if pragmas follow temporaries
	 then we want to insert the break after the last pragma, not after the temporaries."
	(positionParser := aClass newParser)
		initPattern: oldSource
		return:
			[:pattern|
			 positionParser pragmaSequence; temporaries.
			 markBeforePragmas := positionParser startOfNextToken.
			 positionParser pragmaSequence].
	mark := (pragmasFollowTemps := positionParser startOfNextToken > markBeforePragmas)
				ifTrue:
					[positionParser startOfNextToken - 1]
				ifFalse:
					[(hasTemps := positionParser tempsMark <= oldSource size and: [(oldSource at: positionParser tempsMark) = $|])
						ifTrue: [positionParser tempsMark + 2]
						ifFalse: "If no temps, tempsMark points at start of first token in body iff there is a body"
							[positionParser tempsMark >= oldSource size
								ifTrue: "empty body"
									[positionParser startOfNextToken]
								ifFalse:
									[positionParser tempsMark - 1]]].
	newSource := oldSource copyReplaceFrom: mark to: mark - 1 with: '	self break.\' withCRs.
	^methodNode generate copyWithSourceCode: newSource
]

{ #category : #'install-uninstall' }
BreakpointManager class >> forget: breakMethod [
	"Answer the original unbreakpointed method, removing the original from the BreakpointManager's collection.
	 Use with care!!"
	^self installed removeKey: breakMethod ifAbsent: []
]

{ #category : #'install-uninstall' }
BreakpointManager class >> installInClass: aClass selector: aSymbol [ 
	"Install a new method containing a breakpoint.
	The receiver will remember this for unstalling it later"

	| breakMethod |
	breakMethod := self compilePrototype: aSymbol in: aClass.
	breakMethod isNil
		ifTrue: [^ nil].
	self installed at: breakMethod put: aClass >> aSymbol. "old method"
	aClass basicAddSelector: aSymbol withMethod: breakMethod.
]

{ #category : #private }
BreakpointManager class >> installed [
	^Installed ifNil: [Installed := IdentityDictionary new]
]

{ #category : #testing }
BreakpointManager class >> methodHasBreakpoint: aMethod [
	^self installed includesKey: aMethod
]

{ #category : #examples }
BreakpointManager class >> testBreakpoint [
	"In the menu of the methodList, click on -toggle break on entry-
	and evaluate the following:"

	"BreakpointManager testBreakpoint"

	Transcript cr; show: 'Breakpoint test'
]

{ #category : #'install-uninstall' }
BreakpointManager class >> unInstall: breakMethod [ 

	| class selector oldMethod |
	oldMethod := self installed at: breakMethod ifAbsent:[^self].
	class := breakMethod methodClass.
	selector := breakMethod selector.
	
	(class>>selector) == breakMethod ifTrue:[	
			class methodDictionary at: selector put: oldMethod].
	self installed removeKey: breakMethod
]
