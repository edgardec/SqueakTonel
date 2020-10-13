Class {
	#name : #HelpSqueakCorePackagesServiceProvider,
	#superclass : #ServiceProvider,
	#category : #'Help-Squeak-CorePackages'
}

{ #category : #initialization }
HelpSqueakCorePackagesServiceProvider class >> initialize [ 
	ServiceRegistry current buildProvider: self new
]
