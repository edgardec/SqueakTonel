"
EToyGateKeeperMorph new open

""
I am used to control the types of connections a user is willing to allow.
""
"
Class {
	#name : #NebraskaGateKeeperMorph,
	#superclass : #NebraskaCommunicatorMorph,
	#instVars : [
		'counter'
	],
	#classVars : [
		'KnownIPAddresses',
		'UpdateCounter'
	],
	#category : #'Nebraska-Morphs-Experimental'
}

{ #category : #'as yet unclassified' }
NebraskaGateKeeperMorph class >> acceptRequest: requestType from: senderName at: ipAddressString [

	| entry |

	UpdateCounter := self updateCounter + 1.
	entry := self entryForIPAddress: ipAddressString.
	senderName isEmpty ifFalse: [entry latestUserName: senderName].
	^entry requestAccessOfType: requestType
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperMorph class >> acceptableTypesFor: ipAddressString [

	^(self knownIPAddresses at: ipAddressString ifAbsent: [^#()]) acceptableTypes
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperMorph class >> entryForIPAddress: ipAddressString [

	| known entry |

	UpdateCounter := self updateCounter + 1.
	known := self knownIPAddresses.
	entry := known at: ipAddressString ifAbsentPut: [
		entry := NebraskaGateKeeperEntry new.
		entry ipAddress: ipAddressString.
		entry
	].
	^entry
]

{ #category : #'new-morph participation' }
NebraskaGateKeeperMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperMorph class >> knownIPAddresses [

	^KnownIPAddresses ifNil: [KnownIPAddresses := Dictionary new]
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperMorph class >> updateCounter [

	^UpdateCounter ifNil: [UpdateCounter := 0]
]

{ #category : #initialization }
NebraskaGateKeeperMorph >> defaultBorderColor [
	^ Color transparent
]

{ #category : #initialization }
NebraskaGateKeeperMorph >> defaultBorderStyle [
	^ BorderStyle raised
]

{ #category : #initialization }
NebraskaGateKeeperMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 4
]

{ #category : #initialization }
NebraskaGateKeeperMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #initialization }
NebraskaGateKeeperMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self listDirection: #topToBottom;
		 layoutInset: 4;
		 hResizing: #spaceFill;
		 vResizing: #spaceFill;
		 useRoundedCorners;
		 rebuild 
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperMorph >> open [

	self rebuild.
	self openInWorld.
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperMorph >> rebuild [

	self removeAllMorphs.
	self addGateKeeperMorphs.

]

{ #category : #'stepping and presenter' }
NebraskaGateKeeperMorph >> step [

	(self valueOfProperty: #gateKeeperCounterValue) = 
			NebraskaGateKeeperMorph updateCounter ifTrue: [^self].
	self rebuild.

]
