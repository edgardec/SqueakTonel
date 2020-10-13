Class {
	#name : #PackageServices,
	#superclass : #Object,
	#classVars : [
		'ServiceClasses'
	],
	#category : #'PackageInfo-Base'
}

{ #category : #'as yet unclassified' }
PackageServices class >> allServices [
	^ ServiceClasses gather: [:ea | ea services]
]

{ #category : #'as yet unclassified' }
PackageServices class >> initialize [
	ServiceClasses := Set new
]

{ #category : #'as yet unclassified' }
PackageServices class >> register: aClass [
	ServiceClasses add: aClass
]

{ #category : #'as yet unclassified' }
PackageServices class >> unregister: aClass [
	ServiceClasses remove: aClass
]
