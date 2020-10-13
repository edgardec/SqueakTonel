"
A SystemEventManager is EventManager that overrides Object>>actionSequenceForEvent: anEventSelector to supply WeakActionSequenceTrappingErrors as the default event.


"
Class {
	#name : #SystemEventManager,
	#superclass : #EventManager,
	#category : #'System-Change Notification'
}

{ #category : #'events-accessing' }
SystemEventManager >> actionSequenceForEvent: anEventSelector [

    ^(self actionMap
        at: anEventSelector asSymbol
        ifAbsent: [^WeakActionSequenceTrappingErrors new])
            asActionSequenceTrappingErrors
]
