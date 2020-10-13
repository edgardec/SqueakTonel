Class {
	#name : #SparseXTable,
	#superclass : #Object,
	#instVars : [
		'tables',
		'xTables'
	],
	#category : #'Multilingual-Display'
}

{ #category : #accessing }
SparseXTable >> tableFor: code [

	| div |
	div := code // 65536.
	^xTables at: div ifAbsentPut:
		[Array new: 65536 withAll: 0].

]
