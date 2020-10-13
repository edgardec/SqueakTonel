Class {
	#name : #Win32VMTest,
	#superclass : #TestCase,
	#category : #'Tests-VM'
}

{ #category : #tests }
Win32VMTest >> testWinVM3ButtonMousePreference [
	"Ensure that 3ButtonMouse preference is enabled, so that the Win32 VM sends mouse clicks the same way other VMs do"
	| iniData iniPref exePath |
	Smalltalk platformName = 'Win32' ifFalse:[^self].
	exePath := Smalltalk vmFileName.
	iniData := [
		(FileStream readOnlyFileNamed: (exePath copyUpToLast: $.), '.ini')
			 contentsOfEntireFile
	] on: Error do:[:ex| ex return: ''].
	iniPref := false. "default is OFF"
	iniData linesDo:[:line|
		(line beginsWith: '3ButtonMouse') ifTrue:[
			iniPref := (line copyAfter: $=) withBlanksTrimmed ~= '0'.
		].
	].
	self assert: iniPref = true.

]
