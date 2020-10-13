"
I am an Inspector that sends as few messages as possible to collect information about the inspected object. For example, use me to inspect proxies, which are typically subclasses of ProtoObject and hence understand only little messages but make heay use of #doesNotUnderstand:.
"
Class {
	#name : #BasicInspector,
	#superclass : #Inspector,
	#category : #'Tools-Inspector'
}

{ #category : #'as yet unclassified' }
BasicInspector class >> openOn: anObject withLabel: label [
	"Ignore label."
	
	^ ToolBuilder open: (self on: anObject)
]

{ #category : #initialization }
BasicInspector >> basicObjectPrintString [

	^ 'a {1}({2})' format: {thisContext objectClass: object. object identityHash}
]

{ #category : #fields }
BasicInspector >> fieldObjectClass [

	^ (self newFieldForType: #proto key: #class)
		name: 'class'; emphasizeName;
		valueGetter: [:object | thisContext objectClass: object];
		valueGetterExpression: 'thisContext objectClass: self';
		yourself
]

{ #category : #fields }
BasicInspector >> fieldObjectSize [

	^ (self newFieldForType: #proto key: #size)
		name: 'size'; emphasizeName;
		valueGetter: [:object | thisContext objectSize: object];
		valueGetterExpression: 'thisContext objectSize: self';
		yourself
]

{ #category : #fields }
BasicInspector >> fieldSelf [

	^ (self newFieldForType: #self key: #self)
		name: 'self'; emphasizeName;
		valueGetter: [:object | self basicObjectPrintString]; printValueAsIs;
		valueGetterExpression: 'self';
		valueSetter: [:object :value | self object: value];  "Switch to another object-under-inspection."
		yourself
]

{ #category : #initialization }
BasicInspector >> inspect: anObject [ 
	"We don't want to change the inspector class. Only set anObject as the inspectee."
	self object: anObject
]

{ #category : #initialization }
BasicInspector >> labelString [

	^ '{1} {2}{3}' format: {
		'[basic]'.
		self basicObjectPrintString.
		(self object isReadOnlyObject
			ifTrue: [' (read-only)']
			ifFalse: [''])}
]

{ #category : #'fields - streaming' }
BasicInspector >> streamBaseFieldsOn: aStream [

	aStream
		nextPut: self fieldSelf;
		nextPut: self fieldObjectClass;
		nextPut: self fieldObjectSize.
]

{ #category : #'fields - streaming' }
BasicInspector >> streamIndexedVariablesOn: aStream [
	"Truncate indexed variables if there are too many of them."
	
	self
		streamOn: aStream
		truncate: (1 to: (thisContext objectSize: self object))
		collectFields: [:index |
			(self newFieldForType: #indexed key: index)
				name: index asString;
				valueGetter: [:object | thisContext object: object basicAt: index];
				valueGetterExpression: ('thisContext object: {1} basicAt: {2}' format: { 'self'. index }); 
				valueSetter: [:object :value | thisContext object: object basicAt: index put: value];
				yourself]
]

{ #category : #'fields - streaming' }
BasicInspector >> streamInstanceVariablesOn: aStream [

	(thisContext objectClass: self object) allInstVarNames doWithIndex: [:name :index |		
		aStream nextPut: ((self newFieldForType: #instVar key: name)
			name: name asString;
			shouldStyleName: true;
			valueGetter: [:object | thisContext object: object instVarAt: index];
			valueGetterExpression: ('thisContext object: {1} instVarAt: {2}' format: { 'self'. index }); 
			valueSetter: [:object :value | thisContext object: object instVarAt: index put: value];
			yourself)].
]
