"
HTTP progress notification. Includes:
- total: The total size of the download (if known)
- amount: The completed amount of the download (if known)

"
Class {
	#name : #HTTPProgress,
	#superclass : #Notification,
	#instVars : [
		'total',
		'amount'
	],
	#category : #'Network-Protocols'
}

{ #category : #accessing }
HTTPProgress >> amount [
	"Answer the completed amount of the download (if known)"
	^amount
]

{ #category : #accessing }
HTTPProgress >> amount: bytes [
	"Set the completed amount of the download (if known)"
	amount := bytes
]

{ #category : #accessing }
HTTPProgress >> total [
	"Answer the total size of the download, if known"
	^total
]

{ #category : #accessing }
HTTPProgress >> total: bytes [
	"Answer the total size of the download, if known"
	total := bytes
]
