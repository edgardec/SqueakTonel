Class {
	#name : #HelpFlap,
	#superclass : #AlignmentMorph,
	#category : #'Etoys-Squeakland-Etoys-Help'
}

{ #category : #geometry }
HelpFlap >> spanContainerVertically: aSize [
	"Span the receiver's container verticallly, perhaps taking sugar nav bar into account."

	SugarNavigatorBar showSugarNavigator ifFalse: [^ super spanContainerVertically: aSize].
	self height: (aSize - SugarNavigatorBar someInstance height)
]
