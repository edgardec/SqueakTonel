Class {
	#name : #SqueakSSLCertificateError,
	#superclass : #Error,
	#category : #'SqueakSSL-Core'
}

{ #category : #testing }
SqueakSSLCertificateError >> isResumable [
	"Determine whether an exception is resumable."

	^true
]
