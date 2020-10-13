"
I am an Abstract class.
Subclasses of me can create formatted, coloured, and styled copies of Text that is given to them.
They may perform their styling asynchronously, in a background process which I create and manage.

My public interface is...

	view: aViewOrMorph - set the view that will receive notifications when styling has completed.
	
	format: aText - modifies aText's string

	style: aText - modifies the TextAttributes of aText, but does not change the string, then sends #stylerStyled: to the view.

	styleInBackgroundProcess: aText - performs style: in a background process, then sends #stylerStylednBackground: to the view.

	styledTextFor: aText - answers a formatted and styled copy of aText

	unstyledTextFrom: aText - answers a copy of aText with all TextAttributes removed

Subclasses of me should re-implement...

	privateFormat: aText - answer a formatted version of aText; the String may be changed
	privateStyle: aText - modify the TextAttributes of aText; but do not change the String
	

	
	

"
Class {
	#name : #SHTextStyler,
	#superclass : #Object,
	#instVars : [
		'backgroundProcess',
		'view',
		'stylingEnabled'
	],
	#category : #'ShoutCore-Styling'
}

{ #category : #styling }
SHTextStyler >> evaluateWithoutStyling: aBlock [
	| t |
	t := stylingEnabled.
	stylingEnabled := false.
	^ aBlock ensure: [stylingEnabled := t]
]

{ #category : #formatting }
SHTextStyler >> format: aText [
	"Answer a copy of <aText> which has been reformatted,
	or <aText> if no formatting is to be applied"
	
	self terminateBackgroundStylingProcess.
	^self privateFormat: aText
]

{ #category : #styling }
SHTextStyler >> initialize [
	stylingEnabled := true

]

{ #category : #private }
SHTextStyler >> privateFormat: aText [
	self shouldBeImplemented
]

{ #category : #private }
SHTextStyler >> privateStyle: aText [

	self shouldBeImplemented
]

{ #category : #styling }
SHTextStyler >> style: aText [
	
	| text |
	self terminateBackgroundStylingProcess.
	stylingEnabled ifFalse: [ ^self ].
	text := aText copy.
	self privateStyle: text.
	view stylerStyled: text
]

{ #category : #styling }
SHTextStyler >> styleInBackgroundProcess: aText [

	| text newBackgroundProcess |
	self terminateBackgroundStylingProcess.
	stylingEnabled ifFalse: [ ^self ].
	text := aText copy.
	newBackgroundProcess := [
		self privateStyle: text.
		Project current addDeferredUIMessage: [
			view stylerStyledInBackground: text ].
		Processor activeProcess == backgroundProcess ifTrue: [
			backgroundProcess := nil ] ] newProcess
		priority: Processor userBackgroundPriority;
		yourself.
	backgroundProcess ifNil: [
		(backgroundProcess := newBackgroundProcess) resume ]
]

{ #category : #styling }
SHTextStyler >> styledTextFor: aText [
	"Answer a copy of aText that is both formatted and styled"	
	| formattedText |
	
	formattedText := self privateFormat: aText.
	self privateStyle: formattedText.
	^formattedText
]

{ #category : #private }
SHTextStyler >> terminateBackgroundStylingProcess [
	"Terminate the background styling process if it exists. Assume that the first two lines are executed atomically."

	backgroundProcess ifNotNil: [ :backgroundProcessToTerminate |
		backgroundProcess := nil.
		backgroundProcessToTerminate terminate ]
]

{ #category : #styling }
SHTextStyler >> unstyledTextFrom: aText [
	
	^Text fromString: aText string
]

{ #category : #copying }
SHTextStyler >> veryDeepInner: aDeepCopier [

	super veryDeepInner: aDeepCopier.
	backgroundProcess := nil.
	view := view veryDeepCopyWith: aDeepCopier
]

{ #category : #accessing }
SHTextStyler >> view: aViewOrMorph [
	view := aViewOrMorph
]
