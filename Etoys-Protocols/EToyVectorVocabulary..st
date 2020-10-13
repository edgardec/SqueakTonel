"
An extension of the etoy vocabulary in support of an experiment Alan Kay requested in summer 2001 for allowing any morph/player to be thought of as a vector.  In effect, adds a category #vector to the viewer for such all morphs.  Consult Ted Kaehler and Alan Kay for more information on this track.
"
Class {
	#name : #EToyVectorVocabulary,
	#superclass : #EToyVocabulary,
	#category : #'Etoys-Protocols'
}

{ #category : #initialization }
EToyVectorVocabulary >> addCustomCategoriesTo: categoryList [
	"Add any further categories to the default list of viewer categories for an object"

	categoryList add: #vector
]

{ #category : #'method list' }
EToyVectorVocabulary >> allMethodsInCategory: aCategorySymbol forInstance: anObject ofClass: aClass [
	"Answer a list of all methods in the etoy interface which are in the given category, on behalf of anObject, or if it is nil, aClass"

	^ ((anObject isKindOf: Player) and: [aCategorySymbol == #vector])
			ifTrue:
				[anObject costume class vectorAdditions collect:
					[:anAddition | (self methodInterfaceFrom: anAddition) selector]]
			ifFalse:
				[super allMethodsInCategory: aCategorySymbol forInstance: anObject ofClass: aClass]
]

{ #category : #initialization }
EToyVectorVocabulary >> eToyVectorTable [
	"Answer a table of specifications to send to #addFromTable: which add the 'players are vectors' extension to the etoy vocabulary."

	"(selector setterOrNil ((arg name  arg type)...) resultType (category ...) 'help msg' 'wording' autoUpdate)"

	^ #(

(+ nil ((aVector  Player)) Player (geometry) 'Adds two players together, treating each as a vector from the origin.')
(- nil ((aVector  Player)) Player (geometry) 'Subtracts one player from another, treating each as a vector from the origin.')
(* nil ((aVector  Number)) Player (geometry) 'Multiply a player by a number, treating the Player as a vector from the origin.')
(/ nil ((aVector  Number)) Player (geometry) 'Divide a player by a Number, treating the Player as a vector from the origin.')

(incr: nil ((aVector  Player)) unknown (geometry) 'Each Player is a vector from the origin.  Increase one by the amount of the other.' 'increase by')
(decr: nil ((aVector  Player)) unknown (geometry) 'Each Player is a vector from the origin.  Decrease one by the amount of the other.' 'decrease by')
(multBy: nil ((factor  Number)) unknown (geometry) 'A Player is a vector from the origin.  Multiply its length by the factor.' 'multiplied by')
(dividedBy: nil ((factor  Number)) unknown (geometry) 'A Player is a vector from the origin.  Divide its length by the factor.' 'divided by')

"distance and theta are already in Player.  See additionsToViewerCategoryGeometry"
).
]

{ #category : #initialization }
EToyVectorVocabulary >> initialize [
	"Initialize the vocabulary"

	super initialize.
	self addFromTable: self eToyVectorTable.
	self vocabularyName: #Vector.
	self documentation: 'This vocabulary adds to the basic etoy experience an interpretation of "players are vectors", requested by Alan Kay and implemented by Ted Kaehler in summer 2001'.

]
