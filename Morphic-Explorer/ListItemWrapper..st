"
Contributed by Bob Arning as part of the ObjectExplorer package.

"
Class {
	#name : #ListItemWrapper,
	#superclass : #Object,
	#instVars : [
		'item',
		'model'
	],
	#category : #'Morphic-Explorer'
}

{ #category : #'instance creation' }
ListItemWrapper class >> with: anObject [

	^self new setItem: anObject
]

{ #category : #'instance creation' }
ListItemWrapper class >> with: anObject model: aModel [

	^self new setItem: anObject model: aModel
]

{ #category : #'drag and drop' }
ListItemWrapper >> acceptDroppingObject: anotherItem [

	^item acceptDroppingObject: anotherItem
]

{ #category : #converting }
ListItemWrapper >> asString [

	^item asString
]

{ #category : #converting }
ListItemWrapper >> asStringOrText [
	"Documentation only. You can create a custom wrapper that returns text with formatting. The tree widget will then use the text attributes of the first characters and applies them to the entire label. LazyListMorph works the same way."
	
	^ self asString
]

{ #category : #accessing }
ListItemWrapper >> balloonText [

	^nil
]

{ #category : #'drag and drop' }
ListItemWrapper >> canBeDragged [

	^true
]

{ #category : #accessing }
ListItemWrapper >> contents [

	^Array new
]

{ #category : #'event handling' }
ListItemWrapper >> handlesMouseOver: evt [

	^false
]

{ #category : #testing }
ListItemWrapper >> hasContents [

	^self contents isEmpty not
]

{ #category : #testing }
ListItemWrapper >> hasEquivalentIn: aCollection [

	^aCollection anySatisfy: [ :each | 
		each withoutListWrapper = item withoutListWrapper]
]

{ #category : #accessing }
ListItemWrapper >> highlightColor [
	"You can override the current theme's default with a custom value."

	^ nil
]

{ #category : #accessing }
ListItemWrapper >> icon [
	"Answer a form to be used as icon"
	^ nil
]

{ #category : #accessing }
ListItemWrapper >> item [
	^ item
]

{ #category : #accessing }
ListItemWrapper >> itemName [

	^ self item asString
]

{ #category : #accessing }
ListItemWrapper >> model [
	^ model
]

{ #category : #accessing }
ListItemWrapper >> preferredColor [
	"You can override the current theme's default with a custom value."
	
	^ nil
]

{ #category : #setting }
ListItemWrapper >> sendSettingMessageTo: aModel [

	aModel 
		perform: (self settingSelector ifNil: [^self])
		with: self withoutListWrapper

]

{ #category : #initialization }
ListItemWrapper >> setItem: anObject [

	item := anObject.
]

{ #category : #initialization }
ListItemWrapper >> setItem: anObject model: aModel [

	model := aModel.
	self setItem: anObject.
]

{ #category : #private }
ListItemWrapper >> settingSelector [

	^nil
]

{ #category : #'drag and drop' }
ListItemWrapper >> wantsDroppedObject: anotherItem [

	^false
]

{ #category : #converting }
ListItemWrapper >> withoutListWrapper [

	^item withoutListWrapper
]
