"
See PDA comment. 
"
Class {
	#name : #PDAPerson,
	#superclass : #PDARecord,
	#instVars : [
		'name',
		'address',
		'phone',
		'email'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #comparing }
PDAPerson >> <= other [

	^ name <= other name
]

{ #category : #'public access' }
PDAPerson >> address [
	"Return the value of address"
	^ address
]

{ #category : #'public access' }
PDAPerson >> address: newValue [
	"Assign newValue to address."

	address := newValue.
]

{ #category : #'as text' }
PDAPerson >> asListItem [

	^ name
]

{ #category : #'public access' }
PDAPerson >> email [
	"Return the value of email"
	^ email
]

{ #category : #'public access' }
PDAPerson >> email: newValue [
	"Assign newValue to email."

	email := newValue.
]

{ #category : #testing }
PDAPerson >> name [
	"Return the value of name"
	^ name
]

{ #category : #'public access' }
PDAPerson >> name: newValue [
	"Assign newValue to name."

	name := newValue.
]

{ #category : #'public access' }
PDAPerson >> phone [
	"Return the value of phone"
	^ phone
]

{ #category : #'public access' }
PDAPerson >> phone: newValue [
	"Assign newValue to phone."

	phone := newValue.
]
