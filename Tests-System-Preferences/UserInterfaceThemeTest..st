Class {
	#name : #UserInterfaceThemeTest,
	#superclass : #TestCase,
	#instVars : [
		'theme',
		'previous'
	],
	#category : #'Tests-System-Preferences'
}

{ #category : #running }
UserInterfaceThemeTest >> setUp [

	super setUp.
	previous := UserInterfaceTheme current.
	theme := UserInterfaceTheme new name: 'ui theme test'.
]

{ #category : #running }
UserInterfaceThemeTest >> tearDown [

	previous
		ifNil: [UserInterfaceTheme reset]
		ifNotNil: [UserInterfaceTheme current == previous
			ifFalse: [previous apply]].
		
	super tearDown.
]

{ #category : #tests }
UserInterfaceThemeTest >> test01ImplementationHooks [
	"Any class which implements themeProperties must implement #applyUserInterfaceTheme on the instance side."
	
	| problematicClasses |
	problematicClasses := OrderedCollection new.
	Smalltalk allClassesDo: [ : each | ((each theMetaClass includesSelector: #themeProperties) not
		or: [each theNonMetaClass includesSelector: #applyUserInterfaceTheme])
			ifFalse: [problematicClasses add: each]].
	self assert: problematicClasses isEmpty description: ('UI Theme Violations: {1}' format: {(problematicClasses collect: [:ea | ea name]) joinSeparatedBy: ' '})
]

{ #category : #tests }
UserInterfaceThemeTest >> test02SetProperty [

	| m |
	m := UserInterfaceThemeTestObject new.

	theme set: #testColor for: UserInterfaceThemeTestObject to: Color white.
	self assert: m testColor isNil.

	theme apply.
	self assert: Color white equals: m testColor.

]

{ #category : #tests }
UserInterfaceThemeTest >> test03RegisterAndName [

	self deny: (UserInterfaceTheme allThemes includes: theme).
	theme register.
	self assert: (UserInterfaceTheme allThemes includes: theme).
	theme unregister.
	self deny: (UserInterfaceTheme allThemes includes: theme).
	
	theme name: 'test03'.
	theme register.
	self assert: theme == (UserInterfaceTheme named: 'test03').
	theme unregister.
	
	self assert: theme ~~ (UserInterfaceTheme named: 'testXX').
	self assert:  (UserInterfaceTheme named: 'testXX') == (UserInterfaceTheme named: 'testXX').
	(UserInterfaceTheme named: 'testXX') unregister.
	self deny: (UserInterfaceTheme allThemes anySatisfy: [:ea | ea name = 'testXX']).
]

{ #category : #tests }
UserInterfaceThemeTest >> test04SuperClassLookup [

	| m |
	m := UserInterfaceThemeTestObject new.

	theme set: #testColor for: Object to: Color white.
	self assert: m testColor isNil.

	theme apply.
	self assert: Color white equals: m testColor.

]

{ #category : #tests }
UserInterfaceThemeTest >> test05ClearProperty [

	| m |
	m := UserInterfaceThemeTestObject new.
	theme set: #testColor for: UserInterfaceThemeTestObject to: Color white.
	theme apply.

	self assert: Color white equals: m testColor.
	theme clear: #testColor for: UserInterfaceThemeTestObject.
	self assert: Color white equals: m testColor.
	theme apply.
	
	self assert: m testColor isNil.

]

{ #category : #tests }
UserInterfaceThemeTest >> test06SetAndClearUnkownProperty [
	"Unknown means not defined in #themeProperties und used in code such as #applyUserInterfaceTheme."
	
	| m |
	m := UserInterfaceThemeTestObject new.
	theme set: #unknownProperty for: UserInterfaceThemeTestObject to: #blubb.
	theme apply.

	self assert:#blubb equals: m unknownProperty.
	theme clear: #unknownProperty for: UserInterfaceThemeTestObject.
	self assert:#blubb equals: m unknownProperty.
	theme apply.
	
	self assert: m unknownProperty isNil.

]

{ #category : #tests }
UserInterfaceThemeTest >> test07Merge [

	| anotherTheme |
	anotherTheme := UserInterfaceTheme new.
	anotherTheme set: #someColor for: Morph to: Color red.
	anotherTheme set: #thirdColor for: Morph to: Color blue.

	theme set: #myColor for: Morph to: Color white.
	theme set: #thirdColor for: Morph to: Color yellow.
	
	self assert: (theme get: #someColor for: Morph) isNil.
	self assert: (anotherTheme get: #myColor for: Morph) isNil.
	
	theme merge: anotherTheme.
	
	self assert: Color red equals: (theme get: #someColor for: Morph).
	self assert: (anotherTheme get: #myColor for: Morph) isNil.

	"No overwrite."
	self assert: Color yellow equals: (theme get: #thirdColor for: Morph).
	self assert: Color blue equals: (anotherTheme get: #thirdColor for: Morph).

]

{ #category : #tests }
UserInterfaceThemeTest >> test08MergeAndOverwrite [

	| anotherTheme |
	anotherTheme := UserInterfaceTheme new.
	anotherTheme set: #thirdColor for: Morph to: Color blue.
	theme set: #thirdColor for: Morph to: Color yellow.
	
	self assert: Color yellow equals: (theme get: #thirdColor for: Morph).
	self assert: Color blue equals: (anotherTheme get: #thirdColor for: Morph).

	theme merge: anotherTheme overwrite: true.

	self assert: Color blue equals: (theme get: #thirdColor for: Morph).
	self assert: Color blue equals: (anotherTheme get: #thirdColor for: Morph).
]

{ #category : #tests }
UserInterfaceThemeTest >> test09Link [

	| anotherTheme |
	anotherTheme := UserInterfaceTheme new.
	
	anotherTheme set: #testColor for: Object to: Color white.	
	self assert: (theme get: #testColor for: Object) isNil.

	theme link: anotherTheme.
	self assert: theme next == anotherTheme.
	self assert: Color white equals: (theme get: #testColor for: Object).

]

{ #category : #tests }
UserInterfaceThemeTest >> test10Blocks [

	theme set: #testColor for: Object to: [Color r: 1 g: 1 b: 1].
	self assert: (theme get: #testColor for: Object) ~~ (theme get: #testColor for: Object).
	

]

{ #category : #tests }
UserInterfaceThemeTest >> test11LinkAgain [

	| anotherTheme yetAnotherTheme |
	anotherTheme := UserInterfaceTheme new.
	yetAnotherTheme := UserInterfaceTheme new.
	
	yetAnotherTheme set: #testColor for: Object to: Color white.
	self assert: (theme get: #testColor for: Object) isNil.

	theme link: anotherTheme.
	anotherTheme link: yetAnotherTheme.
	
	self assert: Color white equals: (theme get: #testColor for: Object).
]

{ #category : #tests }
UserInterfaceThemeTest >> test12RealDNU [
	"If we forgot to push a scope, it is a real DNU and not stack is empty."
	self should: [theme perform: #undefinedMessage] raise: MessageNotUnderstood
]

{ #category : #tests }
UserInterfaceThemeTest >> test13ClassName [
	
	self assert: (theme get: #testColor for: #Object) isNil.

	theme set: #testColor for: #Object to: Color white.
	self assert: Color white equals: (theme get: #testColor for: #Object).
	
	theme clear: #testColor for: #Object.
	self assert: (theme get: #testColor for: #Object) isNil.

	self shouldnt: [theme set: #testColor for: #SomeNonExistentClass to: Color white] raise: Error.
	self assert: (theme get: #testColor for: nil) isNil.
]

{ #category : #tests }
UserInterfaceThemeTest >> test14Perform [
	
	| m |
	m := UserInterfaceThemeTestObject new.
	theme apply.

	self assert: m getTestColor isNil.
	self assert: m getTestColorViaPerform isNil.

	theme set: #testColor for: #UserInterfaceThemeTestObject to: Color white.

	self assert: Color white equals: m getTestColor.
	self assert: Color white equals: m getTestColorViaPerform.
]

{ #category : #tests }
UserInterfaceThemeTest >> test15DerivedProperties [
	
	theme set: #fanciness for: Point to: 42.
	theme derive: #fanciness for: Rectangle from: Point at: #fanciness.

	self assert: 42 equals: (theme get: #fanciness for: Point).
	self assert: 42 equals: (theme get: #fanciness for: Rectangle).
]

{ #category : #tests }
UserInterfaceThemeTest >> test16ArraysAsProperties [
	"Used, for example, by Shout styling. There might be many reasons for storing arrays as properties."
	
	theme set: #complexSpec for: UserInterfaceThemeTestObject to: {#foo. 42. #(a b c)}.
	
	self assert: {#foo. 42. #(a b c)} equals: (theme get: #complexSpec for: UserInterfaceThemeTestObject).
]

{ #category : #tests }
UserInterfaceThemeTest >> test17DerivedPropertiesWithBlock [
	
	theme set: #fanciness for: Point to: 42.
	theme derive: #fanciness for: Rectangle from: Point at: #fanciness do: [:f | f + 1].

	self assert: 42 equals: (theme get: #fanciness for: Point).
	self assert: 43 equals: (theme get: #fanciness for: Rectangle).
]

{ #category : #tests }
UserInterfaceThemeTest >> test18MergeWithDerivedProperties [
	
	| anotherTheme |
	anotherTheme := UserInterfaceTheme new.
	
	theme set: #fanciness for: Point to: 42.
	theme derive: #fanciness for: Rectangle from: Point at: #fanciness do: [:f | f + 1].

	anotherTheme merge: theme.
	theme set: #fanciness for: Point to: 21.

	self assert: 22 equals: (theme get: #fanciness for: Rectangle).
	self assert: 43 equals: (anotherTheme get: #fanciness for: Rectangle).
]

{ #category : #tests }
UserInterfaceThemeTest >> test19MergeWithCopy [
	
	| anotherTheme |
	anotherTheme := UserInterfaceTheme new.
	
	theme set: #someColor for: Object to: Color red.
	anotherTheme merge: theme.

	self assert: (theme get: #someColor for: Object) ~~ (anotherTheme get: #someColor for: Object).
]

{ #category : #tests }
UserInterfaceThemeTest >> test20ClassSideApply [
	
	UserInterfaceThemeTestObject resetApplyCounter.
	self assert: 0 equals: UserInterfaceThemeTestObject applyCounter.
	theme apply.
	self assert: 1 equals: UserInterfaceThemeTestObject applyCounter.

]

{ #category : #tests }
UserInterfaceThemeTest >> test21BlocksNoDuplicateEvaluation [
	
	| anotherTheme |
	anotherTheme := UserInterfaceTheme new.
	anotherTheme set: #modifier for: Object to: [ [:color | color darker] ].
	
	theme link: anotherTheme.
	self shouldnt: [theme get: #modifier for: Color] raise: Error.	
	self assert: Color yellow darker equals: ((theme get: #modifier for: Color) value: Color yellow).
]

{ #category : #tests }
UserInterfaceThemeTest >> test22SetAndClearConveniently [

	self assert: (theme get: #foo22) isNil.
	theme set: #foo22 to: 22.
	self assert: 22 equals: (theme get: #foo22).
	theme clear: #foo22.
	self assert: (theme get: #foo22) isNil.
]

{ #category : #tests }
UserInterfaceThemeTest >> test23LookUpReset [
	"When nothing is found in the super-class hierarchy, try linked themes. However, start at with the original class again."

	| anotherTheme |
	anotherTheme := UserInterfaceTheme new.
	

	theme set: #fanciness for: Object to: 42.
	theme set: #fanciness for: Point to: 43.
	
	anotherTheme link: theme.

	self assert: 43 equals: (theme get: #fanciness for: Point).
	self assert: 43 equals: (anotherTheme get: #fanciness for: Point).
]

{ #category : #tests }
UserInterfaceThemeTest >> test24GetSimplePropertiesViaLink [

	| anotherTheme |
	anotherTheme := UserInterfaceTheme new.
	
	theme set: #fanciness to: 42.	
	anotherTheme link: theme.

	self assert: 42 equals: (anotherTheme get: #fanciness).
]

{ #category : #tests }
UserInterfaceThemeTest >> test25DerivedPropertiesViaLink [
	"It is not (yet?) possible to reset the look-up for derived properties. You should merge themes if you need it."
	
	| anotherTheme |
	anotherTheme := UserInterfaceTheme new.
	
	theme set: #fanciness for: Point to: 42.
	theme derive: #fanciness for: Rectangle from: Point at: #fanciness do: [:f | f + 1].
	
	anotherTheme set: #fanciness for: Point to: 21.
	anotherTheme link: theme.
	
	self assert: 43 equals: (theme get: #fanciness for: Rectangle).
	"self assert: 22 equals: (anotherTheme get: #fanciness for: Rectangle)."
	self assert: 43 equals: (anotherTheme get: #fanciness for: Rectangle).
]

{ #category : #tests }
UserInterfaceThemeTest >> test26ApplyTo [

	| m |
	m := UserInterfaceThemeTestObject new.

	theme set: #testColor for: UserInterfaceThemeTestObject to: Color white.
	self assert: m testColor isNil.

	theme applyTo: {m}.
	self assert: Color white equals: m testColor.

]

{ #category : #tests }
UserInterfaceThemeTest >> test27DanglingTheme [
	
	self
		assert: (UserInterfaceTheme allThemes includes: UserInterfaceTheme current)
		description: 'The current user interface theme is not registered.'.
]
