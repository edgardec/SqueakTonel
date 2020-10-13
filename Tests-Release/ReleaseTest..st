Class {
	#name : #ReleaseTest,
	#superclass : #TestCase,
	#category : #'Tests-Release'
}

{ #category : #tests }
ReleaseTest >> testClassesSystemCategory [
"Find cases where classes have nil system categories.
This test will tell you the classes.
This is inspired by the proposed fix of a bug in release of 3.10.1 
see Mantis #7070" 
| rejectClasses | 

rejectClasses := 
 nil systemNavigation allClasses reject: [ :each |
	each category notNil ] .

self assert: rejectClasses isEmpty description: ('Classes with nil system categories: {1}' format: {rejectClasses asCommaString}).
]

{ #category : #tests }
ReleaseTest >> testMethodsWithUnboundGlobals [
	| unbound |
	unbound := SystemNavigation default methodsWithUnboundGlobals.
	Smalltalk cleanOutUndeclared. 
	self assert: unbound isEmpty description: 'Unbound: ', unbound asCommaString
]

{ #category : #tests }
ReleaseTest >> testNoObsoleteClasses [

	| obsoleteClasses |
	obsoleteClasses := self systemNavigation obsoleteClasses.
	self 
		assert: obsoleteClasses isEmpty
		description: ('{1} {2} obsolete' format: {
			obsoleteClasses asCommaStringAnd.
			obsoleteClasses size = 1
				ifTrue: [ 'is' ]
				ifFalse: [ 'are' ] })
			
	
]

{ #category : #tests }
ReleaseTest >> testSqueakThemeFonts [
	"Check whether the fonts installed in the active theme in the release are correct"
	
	"preference selector - font family name - font size" 
	{	#(standardDefaultTextFont 'Bitmap DejaVu Sans' 9).
		#(standardListFont 'Bitmap DejaVu Sans' 9).
		#(standardFlapFont 'Bitmap DejaVu Sans' 7).
		#(standardMenuFont 'Bitmap DejaVu Sans' 9).
		#(windowTitleFont 'Bitmap DejaVu Sans' 9).
		#(standardBalloonHelpFont 'Bitmap DejaVu Sans' 7).
		#(standardCodeFont 'Bitmap DejaVu Sans' 9).
		#(standardButtonFont 'Bitmap DejaVu Sans' 7) }
			do: [:triple | | font |
				font := Preferences perform: triple first.
				self assert: triple second equals: font familyName.
				self assert: triple third equals: font pointSize ]
		
	
	
]

{ #category : #tests }
ReleaseTest >> testSuperSubclassReferences [
	"see mantis bug 7090 for more info on this"
	"If the reason for this test to fail is above bug, the following might fix the system"
	"(ProtoObject subclasses reject: [:each | each isMeta or: [each environment includes: each]]) do: [:each | ProtoObject removeSubclass: each]"

	| strangeClasses |
	strangeClasses := ProtoObject allSubclasses reject: [:each | each isMeta or: [each environment includes: each]].
	self assert: strangeClasses isEmpty description: ('Not expecting to find any of {1}' format: {strangeClasses asCommaString}).
]

{ #category : #tests }
ReleaseTest >> testSwapMouseButtonsPreference [
	"Swap mouse buttons should be enabled"
	self assert: Preferences swapMouseButtons
]

{ #category : #tests }
ReleaseTest >> testSystemCategoryClasses [
"Find cases where system categories name absent classes.
This test will tell you the classes.
This is inspired by a bug in release of 3.10.1 
see Mantis #7070" 
|  rejectCats rejectClasses | 
rejectCats := 
SystemOrganization categories reject: [ :catName |
	(SystemOrganization listAtCategoryNamed: catName) 
		allSatisfy: [ :className | 
			( Smalltalk includesKey: className ) ] ] .
"self assert: rejectCats isEmpty ."

rejectCats isEmpty ifTrue: [ ^ true ] . 


rejectClasses :=
rejectCats collect: [ :each |
	each ->
	( (SystemOrganization listAtCategoryNamed: each) 
		reject: [ :eachOne | 
			( Smalltalk includesKey: eachOne )  ] ) ] .

self assert: rejectCats isEmpty description: ('Not expecting any of {1}' format: { rejectClasses asCommaString}).

]

{ #category : #tests }
ReleaseTest >> testUndeclared [
	
	| undeclaredSymbols |
	Smalltalk cleanOutUndeclared. 
	self
		assert: (undeclaredSymbols := Undeclared keys) isEmpty
		description: ('{1} {2} in Undeclared'
			format: {
				undeclaredSymbols asCommaStringAnd.
				undeclaredSymbols size = 1
					ifTrue: [ 'is' ]
					ifFalse: [ 'are' ] })
]
