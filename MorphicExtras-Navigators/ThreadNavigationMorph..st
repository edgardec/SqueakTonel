Class {
	#name : #ThreadNavigationMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'listOfPages',
		'currentIndex',
		'loadedProject'
	],
	#category : #'MorphicExtras-Navigators'
}

{ #category : #examples }
ThreadNavigationMorph class >> example1 [
"
ThreadNavigationMorph example1
"
	self new
		listOfPages: #(
			('ftp://209.143.91.36/Drive A Car')
			('ftp://209.143.91.36/Teachers & NewTech' 1)
			('ftp://209.143.91.36/Teachers & NewTech' 2)
			('ftp://209.143.91.36/Lander')
		);
		openInWorld
]

{ #category : #initialization }
ThreadNavigationMorph >> addButtons [

	self addARow: {
		self inAColumn: {self buttonFirst}.
		self inAColumn: {self buttonPrevious}.
		self inAColumn: {self buttonForward}.
		self inAColumn: {self buttonLast}.
		self inAColumn: {self buttonExit}.
	}.

]

{ #category : #buttons }
ThreadNavigationMorph >> buttonExit [

	^self makeButton: 'Exit' balloonText: 'Exit the sequence' for: #exitTheSequence.



]

{ #category : #buttons }
ThreadNavigationMorph >> buttonFirst [

	^self makeButton: 'First' balloonText: 'First page in sequence' for: #firstPage

]

{ #category : #buttons }
ThreadNavigationMorph >> buttonForward [

	^self makeButton: 'Forward >' balloonText: 'Next page in sequence' for: #nextPage


]

{ #category : #buttons }
ThreadNavigationMorph >> buttonLast [

	^self makeButton: 'Last' balloonText: 'Last page in sequence' for: #lastPage


]

{ #category : #buttons }
ThreadNavigationMorph >> buttonPrevious [

	^self makeButton: '< Back' balloonText: 'Previous page in sequence' for: #previousPage

]

{ #category : #initialization }
ThreadNavigationMorph >> colorForButtons [

	^color darker
]

{ #category : #private }
ThreadNavigationMorph >> currentIndex [

	^currentIndex
]

{ #category : #initialization }
ThreadNavigationMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color red lighter
]

{ #category : #navigation }
ThreadNavigationMorph >> deleteCurrentPage [

	| outerWrapper |

	loadedProject ifNil: [^self].
	outerWrapper := loadedProject world ownerThatIsA: EmbeddedWorldBorderMorph.
	outerWrapper ifNil: [^self].
	outerWrapper delete.
	loadedProject := nil.


]

{ #category : #navigation }
ThreadNavigationMorph >> ensureSuitableDefaults [

	listOfPages ifNil: [listOfPages := OrderedCollection new].
	currentIndex ifNil: [currentIndex := 0].


]

{ #category : #navigation }
ThreadNavigationMorph >> exitTheSequence [

	self deleteCurrentPage.
	self delete.
]

{ #category : #navigation }
ThreadNavigationMorph >> firstPage [

	listOfPages isEmpty ifTrue: [^Beeper beep].
	currentIndex := 1.
	self loadPageWithProgress.
]

{ #category : #initialization }
ThreadNavigationMorph >> fontForButtons [

	^TextStyle defaultFont
]

{ #category : #initialization }
ThreadNavigationMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self layoutInset: 6;
	  hResizing: #shrinkWrap;
	  vResizing: #shrinkWrap;
	  useRoundedCorners;
	  ensureSuitableDefaults;
	  addButtons
]

{ #category : #navigation }
ThreadNavigationMorph >> lastPage [

	listOfPages isEmpty ifTrue: [^Beeper beep].
	currentIndex := listOfPages size.
	self loadPageWithProgress.
]

{ #category : #private }
ThreadNavigationMorph >> listOfPages: aCollection [

	listOfPages := aCollection
]

{ #category : #initialization }
ThreadNavigationMorph >> makeButton: aString balloonText: anotherString for: aSymbol [ 
	^ SimpleButtonDelayedMenuMorph new target: self;
		 borderStyle: BorderStyle raised;
		 color: self colorForButtons;
		 label: aString translated font: self fontForButtons;
		 setBalloonText: anotherString translated;
		 actionSelector: aSymbol
]

{ #category : #private }
ThreadNavigationMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^15		"Navigators are behind menus and balloons, but in front of most other stuff"
]

{ #category : #navigation }
ThreadNavigationMorph >> navigateFromKeystroke: aChar [ 
	"A character was typed in an effort to do interproject navigation along the receiver's thread"

	| ascii |
	ascii := aChar asciiValue.
	(#(29 31 32) includes: ascii) ifTrue: [^self nextPage].	"right arrow, down arrow, space"
	(#(8 28 30) includes: ascii) ifTrue: [^self previousPage].	"left arrow, up arrow, backspace"
	(#(1) includes: ascii) ifTrue: [^self firstPage].
	(#(4) includes: ascii) ifTrue: [^self lastPage].
	Beeper beep
]

{ #category : #navigation }
ThreadNavigationMorph >> nextPage [

	self currentIndex >= listOfPages size ifTrue: [^Beeper beep].
	currentIndex := self currentIndex + 1.
	self loadPageWithProgress.
]

{ #category : #navigation }
ThreadNavigationMorph >> previousPage [

	self currentIndex <= 1 ifTrue: [^Beeper beep].
	currentIndex := self currentIndex - 1.
	self loadPageWithProgress.
]

{ #category : #menu }
ThreadNavigationMorph >> showMenuFor: actionSelector event: evt [

	"no-op here"
]

{ #category : #stepping }
ThreadNavigationMorph >> step [

	| delta |

	owner == self world ifFalse: [^ self].
	owner addMorphInLayer: self.
	delta := self bounds amountToTranslateWithin: self worldBounds.
	delta = (0 @ 0) ifFalse: [self position: self position + delta].

]

{ #category : #stepping }
ThreadNavigationMorph >> stepTime [

	^250
]

{ #category : #stepping }
ThreadNavigationMorph >> wantsSteps [

	^true
]
