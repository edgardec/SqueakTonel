Class {
	#name : #HelpIconsTest,
	#superclass : #TestCase,
	#category : #'HelpSystem-Tests-Core-UI'
}

{ #category : #accessing }
HelpIconsTest >> defaultTestClass [ 
	^HelpIcons
]

{ #category : #tests }
HelpIconsTest >> testIconCaching [
	 
	| first second |
	#(bookIcon pageIcon refreshIcon) do: [:iconSymbol |
		first := self defaultTestClass iconNamed: iconSymbol.
		second := self defaultTestClass iconNamed: iconSymbol.	
		self assert: first notNil.
		self assert: first == second.
	]
	
]
