"
I provide a way to override the current setting of the alternate syntax preference. I am used when filing in code to insure that the Smalltalk-80 preference is used regardless of what the user likes to see in her browsers.
"
Class {
	#name : #RequestAlternateSyntaxSetting,
	#superclass : #Notification,
	#category : #'Etoys-Squeakland-System-Exceptions Kernel'
}

{ #category : #'as yet unclassified' }
RequestAlternateSyntaxSetting >> defaultAction [

        self resume: Preferences printAlternateSyntax
]
