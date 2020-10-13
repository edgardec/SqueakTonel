"
ElementCategory
	
Contains a list of elements that affords keyed access but also has an inherent order.

Add items to the category by sending it elementAt:put:.
Obtain the elements in order by sending #elementsInOrder
Obtain the value of an element at a given key by sending #elementAt:
"
Class {
	#name : #ElementCategory,
	#superclass : #ObjectWithDocumentation,
	#instVars : [
		'categoryName',
		'keysInOrder',
		'elementDictionary'
	],
	#category : #'Protocols-Kernel'
}

{ #category : #initialization }
ElementCategory >> addCategoryItem: anItem [
	"Add the item at the end, obtaining its key from itself (it must respond to #categoryName)"

	self elementAt: anItem categoryName put: anItem
]

{ #category : #'category name' }
ElementCategory >> categoryName [
	"Answer the formal name of the category"

	^ categoryName
]

{ #category : #'category name' }
ElementCategory >> categoryName: aName [
	"Set the category name"

	categoryName := aName
]

{ #category : #initialization }
ElementCategory >> clear [
	"Clear the receiber's keysInOrder and elementDictionary"

	keysInOrder := OrderedCollection new.
	elementDictionary := IdentityDictionary new
]

{ #category : #copying }
ElementCategory >> copyFrom: donor [
	"Copy the receiver's contents from the donor"

	keysInOrder := donor keysInOrder.
	elementDictionary := donor copyOfElementDictionary
]

{ #category : #copying }
ElementCategory >> copyOfElementDictionary [
	"Answer a copy of the element dictionary"

	^ elementDictionary copy
]

{ #category : #elements }
ElementCategory >> elementAt: aKey [
	"Answer the element at the given key"

	^ elementDictionary at: aKey ifAbsent: [nil]
]

{ #category : #elements }
ElementCategory >> elementAt: sym put: element [
	"Add symbol at the end of my sorted list (unless it is already present), and put the element in the dictionary"

	(keysInOrder includes: sym) ifFalse: [keysInOrder add: sym].
	^ elementDictionary at: sym put: element
]

{ #category : #elements }
ElementCategory >> elementSymbol [
	"Answer the element symbol for the receiver.  Here, the categoryName dominates"

	^ categoryName
]

{ #category : #elements }
ElementCategory >> elementsInOrder [
	"Answer the elements in order"

	^ keysInOrder collect: [:aKey | elementDictionary at: aKey]
]

{ #category : #elements }
ElementCategory >> fasterElementAt: sym put: element [
	"Add symbol at the end of my sorted list and put the element in the dictionary.  This variant adds the key at the end of the keys list without checking whether it already exists."

	keysInOrder add: sym.
	^ elementDictionary at: sym put: element
]

{ #category : #keys }
ElementCategory >> includesKey: aKey [
	"Answer whether the receiver's dictionary holds the given key"

	^ elementDictionary includesKey: aKey
]

{ #category : #private }
ElementCategory >> initWordingAndDocumentation [
	"Initialize wording and documentation (helpMessage) for getters and setters"

	self wording: self categoryName
]

{ #category : #initialization }
ElementCategory >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	self clear
]

{ #category : #keys }
ElementCategory >> keysInOrder [
	"Answer the keys in their sorted order"

	^ keysInOrder copy
]

{ #category : #elements }
ElementCategory >> placeKey: key1 afterKey: key2 [
	"Place the first key after the second one in my keysInOrder ordering"

	keysInOrder remove: key1.
	keysInOrder add: key1 after: key2
]

{ #category : #elements }
ElementCategory >> placeKey: key1 beforeKey: key2 [
	"Place the first key before the second one in my keysInOrder ordering"

	keysInOrder remove: key1.
	keysInOrder add: key1 before: key2
]

{ #category : #copying }
ElementCategory >> postCopy [
	"Copy own instance variables."

	super postCopy.
	self copyFrom: self
]

{ #category : #printing }
ElementCategory >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that identifies the receiver."

	super printOn: aStream.
	categoryName ifNotNil: [aStream nextPutAll: ' named ', categoryName asString]
]

{ #category : #elements }
ElementCategory >> removeElementAt: aKey [
	"Remove the element at the given key"

	elementDictionary removeKey: aKey ifAbsent: [^ self].
	keysInOrder remove: aKey ifAbsent: []
]

{ #category : #translation }
ElementCategory >> translated [
	"answer the receiver translated to the current language"
	
	^ self class new categoryName: categoryName asString translated asSymbol
]
