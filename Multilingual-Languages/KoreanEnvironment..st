"
This class provides the Korean support.  Unfortunately, we haven't tested this yet.  We did have a working version in previous implementations, but not this new implementation. But as soon as we find somebody who understand the language, probably we can make it work in two days or so, as we have done for Czech support.
"
Class {
	#name : #KoreanEnvironment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-Languages'
}

{ #category : #'subclass responsibilities' }
KoreanEnvironment class >> clipboardInterpreterClass [
	| platformName osVersion |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	platformName = 'Win32' ifTrue: [^WinKSX1001ClipboardInterpreter].
	platformName = 'Mac OS' 
		ifTrue: 
			[('10*' match: osVersion) 
				ifTrue: [^NoConversionClipboardInterpreter]
				ifFalse: [^WinKSX1001ClipboardInterpreter]].
	platformName = 'unix' 
		ifTrue: 
			[(ShiftJISTextConverter encodingNames includes: X11Encoding getEncoding) 
				ifTrue: [^WinKSX1001ClipboardInterpreter]
				ifFalse: [^NoConversionClipboardInterpreter]].
	^NoConversionClipboardInterpreter
]

{ #category : #'public query' }
KoreanEnvironment class >> defaultEncodingName [
	| platformName osVersion |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	(#('Win32' 'Mac OS' 'ZaurusOS') includes: platformName) 
		ifTrue: [^'euc-kr'].
	(#('unix') includes: platformName) ifTrue: [^'euc-kr'].
	^'mac-roman'
]

{ #category : #'subclass responsibilities' }
KoreanEnvironment class >> inputInterpreterClass [
	| platformName osVersion encoding |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	platformName = 'Win32' ifTrue: [^WinKSX1001InputInterpreter].
	platformName = 'Mac OS' 
		ifTrue: 
			[('10*' match: osVersion) 
				ifTrue: [^MacUnicodeInputInterpreter]
				ifFalse: [^WinKSX1001InputInterpreter]].
	platformName = 'unix' 
		ifTrue: 
			[encoding := X11Encoding encoding.
			(EUCJPTextConverter encodingNames includes: encoding) 
				ifTrue: [^MacRomanInputInterpreter].
			(UTF8TextConverter encodingNames includes: encoding) 
				ifTrue: [^MacRomanInputInterpreter].
			(ShiftJISTextConverter encodingNames includes: encoding) 
				ifTrue: [^MacRomanInputInterpreter]].
	^MacRomanInputInterpreter
]

{ #category : #'subclass responsibilities' }
KoreanEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	^#('ko' )
]

{ #category : #'language methods' }
KoreanEnvironment class >> traditionalCharsetClass [

	^ KSX1001.

]
