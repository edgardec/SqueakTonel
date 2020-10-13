"
CommandLineLauncherExample provides an example for a command line application. if you start squeak with a command line 'class Integer' it will launch a class browser on class Integer.
To enable this execute
CommandLineLauncherExample activate
before you save the image.
To disable execute
CommandLineLauncherExample deactivate
"
Class {
	#name : #CommandLineLauncherExample,
	#superclass : #AbstractLauncher,
	#category : #'System-Download'
}

{ #category : #running }
CommandLineLauncherExample >> startUp [
	| className |
	className := self parameterAt: 'class'.
	ToolSet browse: (Smalltalk at: className asSymbol ifAbsent: [Object]) selector: nil
]
