"
I am a kind of Switch that can be connected to some related object, typically to a collection of my instances. When my instance is created, its connection is set to a particular object. When the object changes because an Switch it refers to is turned on, an update message is broadcasted. All the connected OneOnSwitches, except the changed one, turn off. This allows OneOnSwitches to maintain the constraint that at most one of them will be on at any time. OneOnSwitches can thus be made to act like ""car radio"" switches.
"
Class {
	#name : #OneOnSwitch,
	#superclass : #Switch,
	#instVars : [
		'connection'
	],
	#category : #'ST80-Menus'
}

{ #category : #connection }
OneOnSwitch >> connection [
	"Answer the object that connects the receiver to other Switches."

	^connection
]

{ #category : #connection }
OneOnSwitch >> connection: anObject [ 
	"Set anObject to be the connection among two or more Switches. Make the 
	receiver a dependent of the argument, anObject."

	connection := anObject.
	connection addDependent: self
]

{ #category : #connection }
OneOnSwitch >> isConnectionSet [
	"Answer whether the receiver is connected to an object that coordinates 
	updates among switches."

	connection == nil
		ifTrue: [^false]
		ifFalse: [^true]
]

{ #category : #connection }
OneOnSwitch >> notifyConnection [
	"Send the receiver's connection (if it exists) the message 'changed: self' in 
	order for the connection to broadcast the change to other objects 
	connected by the connection."
	
	self isConnectionSet ifTrue: [self connection changed: self]
]

{ #category : #'initialize-release' }
OneOnSwitch >> release [

	super release.
	self isConnectionSet ifTrue: [connection removeDependent: self]
]

{ #category : #state }
OneOnSwitch >> turnOn [
	"Does nothing if it is already on. If it is not, it is set to 'on', its
	dependents are 	notified of the change, its connection is notified, and
	its action is executed."

	self isOff
		ifTrue: 
			[on := true.
			self changed.
			self notifyConnection.
			self doAction: onAction]
]

{ #category : #updating }
OneOnSwitch >> update: aOneOnSwitch [ 
	"Does nothing if aOneOnSwitch is identical to this object. If it is not, this 
	object is turned off. This message is sent by the connection (an Object)
	when some related OneOnSwitch (possibly this one) has changed. This
	allows a group of related OneOnSwitches to maintain the constraint that
	at most one will be on at any time."

	self ~~ aOneOnSwitch ifTrue: [self turnOff]
]
