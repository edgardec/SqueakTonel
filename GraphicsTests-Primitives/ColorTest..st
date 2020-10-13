Class {
	#name : #ColorTest,
	#superclass : #ClassTestCase,
	#category : #'GraphicsTests-Primitives'
}

{ #category : #failures }
ColorTest >> expectedFailures [

	^ #(testColorsFromPixelValue32BitBlack)
]

{ #category : #tests }
ColorTest >> testAsHTMLColor [

	| table aColorString |
	table := #('0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'A' 'B' 'C' 'D' 'E' 'F').

	table do: [ :each |
		aColorString := '#', each, each, '0000'.
		self assert: (Color fromString: aColorString) asHTMLColor equals: aColorString].

	table do: [ :each |
		aColorString := '#', '00', each, each, '00'.
		self assert: (Color fromString: aColorString) asHTMLColor equals: aColorString].

	table do: [ :each |
		aColorString := '#', '0000', each, each.
		self assert: (Color fromString: aColorString) asHTMLColor equals: aColorString].

	table do: [ :each |
		aColorString := '#', each, each, each, each, each, each.
		self assert: (Color fromString: aColorString) asHTMLColor equals: aColorString].
	
	table do: [ :each |
		aColorString := '#', each, each, each, each, each, each, each, each.
		each = 'F'
			ifTrue: [self assert: (Color fromString: aColorString) asHTMLColor equals: '#FFFFFF' description: 'For full alpha channel the no alpha color is used']
			ifFalse: [self assert: (Color fromString: aColorString) asHTMLColor equals: aColorString]].
]

{ #category : #tests }
ColorTest >> testColorFrom [
	self assert: ((Color colorFrom: #white) asHTMLColor sameAs: '#ffffff').
	self assert: ((Color colorFrom: #(1.0 0.5 0.0)) asHTMLColor sameAs: '#ff8000').
	self assert: ((Color colorFrom: (Color white)) asHTMLColor sameAs: '#ffffff').
	self assert: ((Color colorFrom: '#FF8800') asHTMLColor sameAs: '#ff8800').
	self assert: ((Color colorFrom: '#222222') asHTMLColor sameAs: '#222222').
]

{ #category : #tests }
ColorTest >> testColorsFromPixelValue32BitBlack [

	"This is a test which tests for the particular behavior of
	colorFromPixelValue:depth: which set 32bit rgb black to transparent."
	self assert: Color black equals: (Color colorFromPixelValue: 16rFF000000 depth: 32)
]

{ #category : #tests }
ColorTest >> testConstructorsAreConsistent [
	
	"Color seaFoam asHTMLColor".
	self assert: (Color r: 0 g: 1 b: 128/255) equals: (Color fromString: '#00FF80').
	self assert: (Color r: 0 g: 1 b: 128/255) equals: (Color r: 0 g: 255 b: 128 range: 255).
]

{ #category : #tests }
ColorTest >> testFromString [
	self assert: ((Color fromString: '#FF8800') asHTMLColor sameAs: '#ff8800');
		assert: ((Color fromString: 'FF8800') asHTMLColor sameAs: '#ff8800');
		assert: ((Color fromString: '126,42,33') asHTMLColor sameAs:  '#7E2A21');
		assert: ((Color fromString: '00000000') asHTMLColor sameAs: '#00000000'); "html with alpha channel"
		assert: ((Color fromString: '#8C500BAE') asHTMLColor sameAs: '#8C500BAE');
		assert: ((Color fromString: 'white') asHTMLColor sameAs: '#ffffff');
		assert: ((Color fromString: 'black') asHTMLColor sameAs: '#000000');
		assert: ((Color fromString: nil) asHTMLColor sameAs: '#ffffff');
		assert: ((Color fromString: 'inexistent color') asHTMLColor sameAs: '#ffffff'); "should return white"
		assert: ((Color fromString: 'XXXXXX') asHTMLColor sameAs: '#ffffff') description: 'Color string should be alphanumeric';
		assert: ((Color fromString: '000000000') asHTMLColor sameAs: '#ffffff') description: 'number string too long'. 
		
	self
		assert: (Color fromString: 'DARKGRAY') = Color darkGray description: 'Color can be specified with a case insensitive color name';
		assert: (Color fromString: '#blue') = Color blue description: 'Color can be specified with a leading literal sharp'.
]

{ #category : #tests }
ColorTest >> testHSV [
	"Test the color wheel modulo 360"
	
	self assert: (Color h: 0 s: 1 v: 1) = Color red.
	self assert: (Color h: 60 s: 1 v: 1) = Color yellow.
	self assert: (Color h: 120 s: 1 v: 1) = Color green.
	self assert: (Color h: 180 s: 1 v: 1) = Color cyan.
	self assert: (Color h: 240 s: 1 v: 1) = Color blue.
	self assert: (Color h: 300 s: 1 v: 1) = Color magenta.
	self assert: (Color h: 0+360 s: 1 v: 1) = Color red.
	self assert: (Color h: 120+720 s: 1 v: 1) = Color green.
	self assert: (Color h: 180-360 s: 1 v: 1) = Color cyan.
	self assert: (Color h: 240-720 s: 1 v: 1) = Color blue.
]

{ #category : #tests }
ColorTest >> testMultiplyByArray [
	| newColor oldColor tolerance |
	tolerance := 0.001.

	oldColor := Color r: 0.75 g: 0.5 b: 0.25.
	newColor := oldColor * #(0.1 2 3).

	self assert: (0.075 - newColor red) abs < tolerance.
	self assert: (1 - newColor green) abs < tolerance.
	self assert: (0.75 - newColor blue) abs < tolerance.
]

{ #category : #tests }
ColorTest >> testMultiplyByArrayIdentityTransform [
	| newColor oldColor tolerance |
	tolerance := 0.001.

	oldColor := Color r: 0.75 g: 0.5 b: 0.25.
	newColor := oldColor * 2.

	self assert: (1 - newColor red) abs < tolerance.
	self assert: (1 - newColor green) abs < tolerance.
	self assert: (0.5 - newColor blue) abs < tolerance.
]

{ #category : #tests }
ColorTest >> testMultiplyByNumber [
	| newColor oldColor tolerance |
	tolerance := 0.001.

	oldColor := Color r: 0.75 g: 0.5 b: 0.25.
	newColor := oldColor * 2.

	self assert: (1 - newColor red) abs < tolerance.
	self assert: (1 - newColor green) abs < tolerance.
	self assert: (0.5 - newColor blue) abs < tolerance.
]

{ #category : #tests }
ColorTest >> testPrintHtmlString [
	"self debug: #testPrintHtmlString"
	
	"test the semantic of components"
	self assert: Color white printHtmlString = 'FFFFFF'.
	self assert: Color red printHtmlString =  'FF0000'.
	self assert: Color green printHtmlString =  '00FF00'.
	self assert: Color blue printHtmlString =  '0000FF'.
	self assert: Color black printHtmlString = '000000'.
	
	"test all possible values for each component (but no combinatorial)"
	16r00 to: 16rFF do:
		[:component |
		| xx o roo ogo oob |
		xx := component printStringBase: 16 length: 2 padded: true.
		o := '00'.
		roo := xx , o , o.
		ogo := o , xx , o.
		oob := o , o , xx.
		self assert: roo equals: (Color fromString: '#' , roo) printHtmlString.
		self assert: ogo equals: (Color fromString: '#' , ogo) printHtmlString.
		self assert: oob equals: (Color fromString: '#' , oob) printHtmlString].
]
