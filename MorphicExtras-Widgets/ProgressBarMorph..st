Class {
	#name : #ProgressBarMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'value',
		'progressColor',
		'lastValue'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #menu }
ProgressBarMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addList: {
		{'progress color...' translated. #changeProgressColor:}.
		{'progress value...' translated. #changeProgressValue:}.
		}
]

{ #category : #menu }
ProgressBarMorph >> changeProgressColor: evt [
	| aHand |
	aHand := evt ifNotNil: [evt hand] ifNil: [self primaryHand].
	self changeColorTarget: self selector: #progressColor: originalColor: self progressColor hand: aHand.
]

{ #category : #menu }
ProgressBarMorph >> changeProgressValue: evt [
	| answer |
	answer := UIManager default
		request: 'Enter new value (0 - 1.0)'
		initialAnswer: self value contents asString.
	answer isEmptyOrNil ifTrue: [^ self].
	self value contents: answer asNumber
]

{ #category : #drawing }
ProgressBarMorph >> drawOn: aCanvas [
	| width inner |
	super drawOn: aCanvas.
	inner := self innerBounds.
	width := (inner width * lastValue) truncated min: inner width.
	aCanvas fillRectangle: (inner origin extent: width @ inner height) color: progressColor.
]

{ #category : #initialization }
ProgressBarMorph >> initialize [
	super initialize.
	self setDefaultParameters.
	self value: (ValueHolder new contents: 0.0).
	lastValue := 0.0
]

{ #category : #accessing }
ProgressBarMorph >> progressColor [
	^progressColor
]

{ #category : #accessing }
ProgressBarMorph >> progressColor: aColor [
	progressColor = aColor
		ifFalse:
			[progressColor := aColor.
			self changed]
]

{ #category : #initialization }
ProgressBarMorph >> setDefaultParameters [

	self
		borderColor: ((UserInterfaceTheme current get: #borderColor for: SystemProgressBarMorph) ifNil: [Color black]);
		borderWidth: ((UserInterfaceTheme current get: #borderWidth for: SystemProgressBarMorph) ifNil: [2]);
		color: ((UserInterfaceTheme current get: #color for: SystemProgressBarMorph) ifNil: [Color white]);
		progressColor: ((UserInterfaceTheme current get: #barColor for: SystemProgressBarMorph) ifNil: [Color green]).
]

{ #category : #updating }
ProgressBarMorph >> update: aSymbol [ 
	aSymbol == #contents
		ifTrue: 
			[lastValue := value contents.
			self changed]
]

{ #category : #accessing }
ProgressBarMorph >> value [
	^value
]

{ #category : #accessing }
ProgressBarMorph >> value: aModel [
	value ifNotNil: [value removeDependent: self].
	value := aModel.
	value ifNotNil: [value addDependent: self]
]
