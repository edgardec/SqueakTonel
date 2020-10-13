Class {
	#name : #BorderedMorphTests,
	#superclass : #TestCase,
	#category : #'MorphicTests-Basic'
}

{ #category : #tests }
BorderedMorphTests >> test01OldInstVarRefs [
	"Only BorderedMorph should reference the (deprecated) borderWidth and borderColor isntance variables."
	
	self
		assert: 2
		equals: (SystemNavigation default allAccessesTo: #borderWidth from: BorderedMorph) size.
		
	self
		assert: 2
		equals: (SystemNavigation default allAccessesTo: #borderColor from: BorderedMorph) size.
]

{ #category : #tests }
BorderedMorphTests >> test02ConvertColorSymbols [
	"The use of #inset or #raised as border color should result in the use of a new border style."
	
	| sut |
	sut := BorderedMorph new.
	self
		assert: #simple equals: sut borderStyle style;
		assert: Color black equals: sut borderStyle color.
	
	sut borderColor: #raised.
	self
		assert: #raised equals: sut borderStyle style;
		assert: Color black equals: sut borderStyle color.
	
	"Enable color tracking."
	sut borderColor: Color transparent.
	self assert: sut color equals: sut borderStyle color.
	
	sut borderColor: #inset.
	self
		assert: #inset equals: sut borderStyle style;
		assert: sut color equals: sut borderStyle color.

]

{ #category : #tests }
BorderedMorphTests >> test03ColorTracking [
	
	| sut c1 c2 |
	sut := BorderedMorph new.
	self assert: Color black equals: sut borderStyle baseColor.

	sut borderInset.
	self
		assert: Color transparent equals: sut borderStyle baseColor;
		assert: sut borderStyle topLeftColor ~= sut color;
		assert: sut borderStyle bottomRightColor ~= sut color;
		assert: sut borderStyle bottomRightColor ~= sut borderStyle topLeftColor.

	c1 := sut borderStyle topLeftColor.
	c2 := sut borderStyle bottomRightColor.
	sut color: Color yellow.
	self
		assert: Color transparent equals: sut borderStyle baseColor;
		assert: sut borderStyle topLeftColor ~= c1;
		assert: sut borderStyle bottomRightColor ~= c2.

	c1 := sut borderStyle topLeftColor.
	c2 := sut borderStyle bottomRightColor.		
	sut borderStyle: BorderStyle raised.
	self
		assert: Color transparent equals: sut borderStyle baseColor;
		assert: sut borderStyle topLeftColor = c2;
		assert: sut borderStyle bottomRightColor = c1.
]

{ #category : #tests }
BorderedMorphTests >> test04InnerBounds [
	"Check whether a changed border width triggers a layout re-computation."
	
	| sut |
	sut := Morph new.
	sut changeTableLayout.
	sut addMorph: (Morph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself).
	
	self
		assert: 0 equals: sut borderWidth;
		assert: sut fullBounds equals: sut bounds;
		assert: sut bounds equals: sut innerBounds;
		assert: sut bounds equals: sut firstSubmorph bounds.

	sut borderStyle: (BorderStyle raised width: 10).
	
	self
		assert: 10 equals: sut borderWidth;
		assert: sut fullBounds equals: sut bounds;
		assert: (sut bounds insetBy: 10) equals: sut innerBounds;
		assert: sut innerBounds equals: sut firstSubmorph bounds.
]

{ #category : #tests }
BorderedMorphTests >> test05Convenience [
	"Check whether a the convenience messages #borderWidth: and #borderColor: work."
	
	| sut |
	sut := Morph new.
	sut
		borderWidth: 5;
		borderColor: Color yellow.
		
	self
		assert: 5 equals: sut borderWidth;
		assert: Color yellow equals: sut borderColor.
	
	sut := Morph new.
	sut
		borderColor: Color yellow;
		borderWidth: 5.
		
	self
		assert: Color yellow equals: sut borderColor;
		assert: 5 equals: sut borderWidth.
]
