"
RecentMessagesTest uses me to show how it behaves when classes don't want to log to a change set.
"
Class {
	#name : #WantsChangeSetLogging,
	#superclass : #Object,
	#classVars : [
		'WantsChangeSetLoggingFlag'
	],
	#category : #'Tests-System-Support'
}

{ #category : #'instance creation' }
WantsChangeSetLogging class >> no [
	 WantsChangeSetLoggingFlag := false.
]

{ #category : #compiling }
WantsChangeSetLogging class >> wantsChangeSetLogging [
	^ WantsChangeSetLoggingFlag ifNil: [^true]
]

{ #category : #'instance creation' }
WantsChangeSetLogging class >> yes [
	 WantsChangeSetLoggingFlag := true.
]
