"
Instances of this morph get used by SystemProgressMoprh to quickly display a progress bar.
"
Class {
	#name : #SystemProgressBarMorph,
	#superclass : #Morph,
	#instVars : [
		'barSize',
		'barColor'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #preferences }
SystemProgressBarMorph class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the progress bar''s border.' }.
		{ #borderWidth. 'Borders'. 'Width of the progress bar''s border.' }.
		{ #borderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset.' }.
		{ #color. 'Colors'. 'Background color of the progress bar.' }.
		{ #barColor. 'Colors'. 'Color of the progress bar''s bar.' }.
	}
]

{ #category : #updating }
SystemProgressBarMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self setDefaultParameters.
]

{ #category : #accessing }
SystemProgressBarMorph >> barColor [

	^ barColor
]

{ #category : #accessing }
SystemProgressBarMorph >> barColor: aColor [

	| cc fill |
	cc := aColor.

	MenuMorph gradientMenu
		ifFalse: [fill := SolidFillStyle color: cc]
		ifTrue: [
			fill := GradientFillStyle ramp: { 
				0.0 -> cc twiceLighter. 
				1 -> cc twiceDarker }].

	barColor := fill.
	self changed.
]

{ #category : #accessing }
SystemProgressBarMorph >> barSize [

	^ barSize
]

{ #category : #accessing }
SystemProgressBarMorph >> barSize: anInteger [
	barSize := anInteger.
	self changed.
]

{ #category : #drawing }
SystemProgressBarMorph >> drawOn: aCanvas [

	| area fill |
	super drawOn: aCanvas.
	
	self barSize > 0 ifTrue: [
		area := self innerBounds.
		area := area origin extent: (self barSize min: area extent x)@area extent y.

		fill := self barColor isColor
			ifTrue: [SolidFillStyle color: self barColor]
			ifFalse: [self barColor].
		fill isGradientFill ifTrue: [
			fill origin: area origin.
			fill direction: 0@ area height].

		aCanvas
			frameAndFillRectangle: area
			fillStyle: fill
			borderStyle: (SimpleBorder new width: 1; color: fill asColor muchDarker).
	].

]

{ #category : #initialization }
SystemProgressBarMorph >> initialize [
	super initialize.

	self setDefaultParameters.
	barSize := 0.

]

{ #category : #initialization }
SystemProgressBarMorph >> setDefaultParameters [
	"change the receiver's appareance parameters"

	self
		color: (self userInterfaceTheme color ifNil: [Color r: 0.977 g: 0.977 b: 0.977]);
		borderStyle: (self userInterfaceTheme borderStyle ifNil: [BorderStyle simple]) copy;
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color transparent]);
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [0]);
		barColor: (self userInterfaceTheme barColor ifNil: [Color r: 0.72 g: 0.72 b: 0.9]).
]
