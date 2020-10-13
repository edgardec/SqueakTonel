Class {
	#name : #XTableForUnicodeFont,
	#superclass : #Object,
	#instVars : [
		'ranges',
		'xTables'
	],
	#category : #'Multilingual-Display'
}

{ #category : #accessing }
XTableForUnicodeFont >> at: indexPlusOne [

	| index |
	index := indexPlusOne.
	ranges with: xTables do: [:range :xTable |
		(range first <= index and: [index <= range last]) ifTrue: [
			^ xTable at: index - range first + 1.
		].
	].
	^ 0.

]

{ #category : #accessing }
XTableForUnicodeFont >> at: index put: value [

	ranges with: xTables do: [:range :xTable |
		(range first <= index and: [index <= range last]) ifTrue: [
			^ xTable at: index - range first + 1 put: value.
		].
	].
	^ 0.

]

{ #category : #accessing }
XTableForUnicodeFont >> ranges: pairArray [

	xTables := Array new: 0.
	pairArray do: [:range |
		xTables := xTables copyWith: (Array new: range last - range first + 1 withAll: 0).
	].
	ranges := pairArray.

]

{ #category : #accessing }
XTableForUnicodeFont >> size [

	^ ranges last last - ranges first first + 1.

]
