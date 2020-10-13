"
The interim record of ancestry for a working copy, gets merged version added to the ancestry, and is used to create the VersionInfo when the working copy becomes a version. 
"
Class {
	#name : #MCWorkingAncestry,
	#superclass : #MCAncestry,
	#category : #'Monticello-Versioning'
}

{ #category : #accessing }
MCWorkingAncestry >> addAncestor: aNode [
	ancestors := (self ancestors reject: [:each | aNode hasAncestor: each])
		copyWith: aNode
]

{ #category : #accessing }
MCWorkingAncestry >> addStepChild: aVersionInfo [
	stepChildren := stepChildren copyWith: aVersionInfo
]

{ #category : #versions }
MCWorkingAncestry >> infoWithName: nameString message: messageString [
	^ MCVersionInfo
		name: nameString
		id: UUID new
		message: messageString
		date: Date today
		time: Time now
		author: Utilities authorInitials
		ancestors: ancestors asArray
		stepChildren: self stepChildren asArray
]

{ #category : #testing }
MCWorkingAncestry >> name [
	^ '<working copy>'
]

{ #category : #operations }
MCWorkingAncestry >> reparent: aNode [
	"Let aNode be the sole parent of this version"
	ancestors := { aNode }

]

{ #category : #accessing }
MCWorkingAncestry >> summary [
	^ 'Ancestors: ', self ancestorString
]
