"
A mainainable object is a personal object that is of such a complexity that it seems beneficial to optionally co-maintain with other people.
It thus has a potential list of maintainers - other accounts that also can modify the object. It also has a field to be able to refer to an RSS feed regarding the object.
"
Class {
	#name : #SMMaintainableObject,
	#superclass : #SMPersonalObject,
	#instVars : [
		'maintainers',
		'rss',
		'feedbackEmail'
	],
	#category : #'SMBase-domain'
}

{ #category : #maintainers }
SMMaintainableObject >> addMaintainer: anAccount [
	"Add anAccount as a maintainer."

	maintainers ifNil: [maintainers := OrderedCollection new].
	maintainers add: anAccount.
	anAccount addCoObject: self
]

{ #category : #deletion }
SMMaintainableObject >> delete [
	"Disconnect from maintainers."

	super delete.
	maintainers ifNotNil: [
		maintainers copy do: [:m | self removeMaintainer: m]]
]

{ #category : #maintainers }
SMMaintainableObject >> feedbackEmail [
	^feedbackEmail
]

{ #category : #maintainers }
SMMaintainableObject >> feedbackEmail: anEmail [
	feedbackEmail := anEmail
]

{ #category : #testing }
SMMaintainableObject >> isOwnerOrMaintainer: anAccount [
	^ owner = anAccount or: [self maintainers includes: anAccount]
]

{ #category : #maintainers }
SMMaintainableObject >> maintainers [
	"Return all maintainers."

	^maintainers ifNil: [#()]
]

{ #category : #maintainers }
SMMaintainableObject >> removeMaintainer: anAccount [
	"Remove anAccount as a maintainer."

	maintainers ifNil: [^self].
	maintainers remove: anAccount.
	anAccount removeCoObject: self
]

{ #category : #maintainers }
SMMaintainableObject >> rss [
	^rss
]

{ #category : #maintainers }
SMMaintainableObject >> rss: anUrl [
	anUrl = 'nil'
		ifTrue: [rss := nil]
		ifFalse: [rss := anUrl]
]
