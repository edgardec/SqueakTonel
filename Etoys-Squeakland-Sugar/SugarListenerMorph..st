Class {
	#name : #SugarListenerMorph,
	#superclass : #NebraskaListenerMorph,
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #'as yet unclassified' }
SugarListenerMorph class >> ensureListenerInCurrentWorld [


]

{ #category : #'as yet unclassified' }
SugarListenerMorph >> addNewObject: newObject thumbForm: aForm sentBy: senderName ipAddress: ipAddressString [

	newObject openInHand.
	self class removeAllFromGlobalIncomingQueue.
	self position: -200@ -200.
]
