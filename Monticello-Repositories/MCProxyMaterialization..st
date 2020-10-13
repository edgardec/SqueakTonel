Class {
	#name : #MCProxyMaterialization,
	#superclass : #Notification,
	#instVars : [
		'proxy'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #'as yet unclassified' }
MCProxyMaterialization class >> signalMaterializing: aMCInfoProxy [
	^ self new
		setProxy: aMCInfoProxy;
		signal
]

{ #category : #handling }
MCProxyMaterialization >> defaultAction [
	self resume: proxy materializeInfo
]

{ #category : #'initialize-release' }
MCProxyMaterialization >> setProxy: aMCInfoProxy [
	proxy := aMCInfoProxy
]
