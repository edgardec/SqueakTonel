Class {
	#name : #PreDebugWindow,
	#superclass : #SystemWindow,
	#instVars : [
		'proceedButton',
		'debugButton'
	],
	#category : #'Etoys-Squeakland-Morphic-Windows'
}

{ #category : #'new-morph participation' }
PreDebugWindow class >> includeInNewMorphMenu [
	^ false
]

{ #category : #'as yet unclassified' }
PreDebugWindow >> adjustBookControls [
	| inner |
	proceedButton ifNil: [^ self].
	proceedButton align: proceedButton topLeft with: (inner := self innerBounds) topLeft + (35@ -4).
	debugButton align: debugButton topRight with: inner topRight - (16@4).
]

{ #category : #'as yet unclassified' }
PreDebugWindow >> createMethod [
	model createMethod
]

{ #category : #'as yet unclassified' }
PreDebugWindow >> debug [
	model debug
]

{ #category : #geometry }
PreDebugWindow >> extent: newExtent [
	super extent: (newExtent max: 100 @ 50).
	self adjustBookControls
]

{ #category : #initialization }
PreDebugWindow >> initialize [
	| aFont proceedLabel debugLabel aWidth |
	super initialize.
	true 
		ifFalse: 
			["Preferences optionalMorphicButtons"

			(aWidth := self widthOfFullLabelText) > 280 ifTrue: [^self].	"No proceed/debug buttons if title too long"
			debugLabel := aWidth > 210 
				ifTrue: 
					["Abbreviated buttons if title pretty long"

					proceedLabel := 'p'.
					'd']
				ifFalse: 
					["Full buttons if title short enough"

					proceedLabel := 'proceed'.
					'debug'].
			aFont := Preferences standardEToysButtonFont.
			self addMorph: (proceedButton := (SimpleButtonMorph new)
								borderWidth: 0;
								label: proceedLabel font: aFont;
								color: Color transparent;
								actionSelector: #proceed;
								target: self).
			proceedButton setBalloonText: 'continue execution'.
			self addMorph: (debugButton := (SimpleButtonMorph new)
								borderWidth: 0;
								label: debugLabel font: aFont;
								color: Color transparent;
								actionSelector: #debug;
								target: self).
			debugButton setBalloonText: 'bring up a debugger'.
			proceedButton submorphs first color: Color blue.
			debugButton submorphs first color: Color red].
	self adjustBookControls
]

{ #category : #'as yet unclassified' }
PreDebugWindow >> proceed [
	model proceed
]

{ #category : #'as yet unclassified' }
PreDebugWindow >> sendReport [
	model storeLog; sendReport.
]

{ #category : #'as yet unclassified' }
PreDebugWindow >> setBalloonTextForCloseBox [
	closeBox ifNotNil:
		[closeBox setBalloonText: 'abandon this execution by closing this window' translated].

]

{ #category : #label }
PreDebugWindow >> setLabelWidgetAllowance [
	^ labelWidgetAllowance := (Smalltalk isMorphic | Preferences optionalButtons)
		ifTrue:
			[super setLabelWidgetAllowance]
		ifFalse:
			[180]
]

{ #category : #'as yet unclassified' }
PreDebugWindow >> storeLog [
	model storeLog
]
