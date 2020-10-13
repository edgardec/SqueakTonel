"
This class is used to restore the VM's view of the power manage option. On the macintosh in a 3.x VM  you can  turn the power manager on or off. This may make your iBook run faster, and will prevents your macintosh from sleeping. This does consume more power so your battery life will be degraded. 

Usually you can turn processor cycling off in the control panel, but this class ensures it's off if you set the preference to turn power management off
"
Class {
	#name : #PowerManagement,
	#superclass : #Object,
	#category : #'System-Support'
}

{ #category : #'startup logic' }
PowerManagement class >> deinstall [
	"PowerManagement deinstall"

	Smalltalk removeFromStartUpList: self.

]

{ #category : #'power management' }
PowerManagement class >> disablePowerManager [
	self disablePowerManager: 1
]

{ #category : #'power management' }
PowerManagement class >> disablePowerManager: aInteger [ 
	"Disable/Enable the architectures power manager by passing in nonzero 
	or zero"
	<primitive: 'primitiveDisablePowerManager'> "primitiveExternalCall" 
	^ self
]

{ #category : #'power management' }
PowerManagement class >> enablePowerManager [
	self disablePowerManager: 0
]

{ #category : #'class initialization' }
PowerManagement class >> initialize [
	"PowerManagement initialize"

	Smalltalk addToStartUpList: self
]

{ #category : #computing }
PowerManagement class >> itsyVoltage [
	"On the Itsy, answer the approximate Vcc voltage. The Itsy will shut 
	itself down when this value reaches 2.0 volts. This method allows one to 
	build a readout of the current battery condition."
	| n |
	n := Smalltalk getSystemAttribute: 1200.
	n
		ifNil: [^ 'no voltage attribute'].
	^ (n asNumber / 150.0 printShowingMaxDecimalPlaces: 2) , ' volts'
]

{ #category : #'startup logic' }
PowerManagement class >> startUp [
	[Preferences turnOffPowerManager
		ifTrue: [self disablePowerManager]]
		ifError: []
]
