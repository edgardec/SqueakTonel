Class {
	#name : #MCWorkingHistoryBrowser,
	#superclass : #MCVersionHistoryBrowser,
	#category : #'Monticello-UI'
}

{ #category : #accessing }
MCWorkingHistoryBrowser >> baseSnapshot [
	^ package snapshot
]
