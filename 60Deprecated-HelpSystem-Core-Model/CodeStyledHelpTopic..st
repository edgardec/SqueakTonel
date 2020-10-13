"
A CodeStyledHelpTopic is a simple way to make sure a help topic gets styled for code in a help browser. Once the help browser is able to code-style individual chunks instead of having to brute-force entire pages we can remove this class and simplify thngs
"
Class {
	#name : #CodeStyledHelpTopic,
	#superclass : #HelpTopic,
	#category : #'60Deprecated-HelpSystem-Core-Model'
}

{ #category : #testing }
CodeStyledHelpTopic >> usesCodeStyling [
	"do I need a styled (ie with Shout) browser page?"
	^true
]
