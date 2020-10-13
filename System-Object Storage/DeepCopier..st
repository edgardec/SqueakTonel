"
DeepCopier does a veryDeepCopy.  

It is a complete tree copy using a dictionary.  Any object that is in the tree twice is only copied once.  All references to the object in the copy of the tree will point to the new copy.  See Object|veryDeepCopy which calls (self veryDeepCopyWith: aDeepCopier).

The dictionary of objects that have been seen, holds the correspondance (uniClass -> new uniClass).

When a tree of morphs points at a morph outside of itself, that morph should not be copied.  Use our own kind of weak pointers for the 'potentially outside' morphs.   Default is that any new class will have all of its fields deeply copied.  If a field needs to be weakly copied, define veryDeepInner: and veryDeepFixupWith:.
     veryDeepInner: has the loop that actually copies the fields.  If a class defines its own copy of veryDeepInner: (to leave some fields out), then veryDeepFixupWith: will be called on that object at the end.  veryDeepInner: can compute an alternate object to put in a field.  (Object veryDeepCopyWith: discovers which superclasses did not define veryDeepInner:, and very deeply copies the variables defined in those classes).
	To decide if a class needs veryDeepInner: and veryDeepFixupWith:, ask this about an instance:  If I duplicate this object, does that mean that I also want to make duplicates of the things it holds onto?  If yes, (i.e. a Paragraph does want a new copy of its Text) then do nothing.  If no, (i.e. an undo command does not want to copy the objects it acts upon), then define veryDeepInner: and veryDeepFixupWith:.
	
Here is an analysis for the specific case of a morph being held by another morph.  
Does field X contain a morph (or a Player whose costume is a morph)?  If not, no action needed.
Is the morph in field X already a submorph of the object?  Is it down lower in the submorph tree?
	If so, no action needed.
Could the morph in field X every appear on the screen (be a submorph of some other morph)?
	If not, no action needed.
	If it could, you must write the methods veryDeepFixupWith:   and   veryDeepInner:, and in them, refrain from sending veryDeepCopyWith: to the contents of field X.

newUniClasses =   true in the normal case.  Every duplicated Player gets a new class.  When false, all duplicates will be siblings (sister instances) of existing players.


----- Things Ted is still considering -----
Rule:  If a morph stores a uniClass class (Player 57) as an object in a field, the new uniClass will not be stored there.   Each uniClass instance does have a new class created for it.  (fix this by putting the old class in references and allow lookup?  Wrong if encounter it before seeing an instance?)

Rule: If object A has object C in a field, and A says (^ C) for the copy, but object B has A in a normal field and it gets deepCopied, and A in encountered first, then there will be two copies of C.  (just be aware of it)

Dependents are now fixed up.  Suppose a model has a dependent view.  In the DependentFields dictionary, model -> (view ...).  
	If only the model is copied, no dependents are created (no one knows about the new model).  
	If only the view is copied, it is inserted into DependentFields on the right side.  model -> (view  copiedView ...).  
	If both are copied, the new model has the new view as its dependent.
	If additional things depend on a model that is copied, the caller must add them to its dependents.

"
Class {
	#name : #DeepCopier,
	#superclass : #Object,
	#instVars : [
		'references',
		'uniClasses',
		'newUniClasses'
	],
	#category : #'System-Object Storage'
}

{ #category : #'instance creation' }
DeepCopier class >> new: requestedSize [

	^self basicNew initialize: requestedSize
]

{ #category : #'like fullCopy' }
DeepCopier >> checkBasicClasses [
	"Check that no indexes of instance vars have changed in certain classes.  If you get an error in this method, an implementation of veryDeepCopyWith: needs to be updated.  The idea is to catch a change while it is still in the system of the programmer who made it.  
	DeepCopier new checkVariables	"

	| str str2 objCls morphCls playerCls |
	str := '|veryDeepCopyWith: or veryDeepInner: is out of date.'.
	(objCls := self objInMemory: #Object) ifNotNil: [
		objCls instSize = 0 ifFalse: [self error: 
			'Many implementers of veryDeepCopyWith: are out of date']].
	(morphCls := self objInMemory: #Morph) ifNotNil: [
		morphCls superclass == Object ifFalse: [self error: 'Morph', str].
		(morphCls instVarNames copyFrom: 1 to: 6) = #('bounds' 'owner' 'submorphs' 
				'fullBounds' 'color' 'extension') 
			ifFalse: [self error: 'Morph', str]].	"added ones are OK"

	str2 := 'Player|copyUniClassWith: and DeepCopier|mapUniClasses are out of date'.
	(playerCls := self objInMemory: #Player) ifNotNil: [
		playerCls class instVarNames = #('scripts' 'slotInfo' 'variableDocks')
			ifFalse: [self error: str2]].

]

{ #category : #'like fullCopy' }
DeepCopier >> checkClass: aClass [
	| meth |
	"Check that no indexes of instance vars have changed in certain classes.  If you get an error in this method, an implementation of veryDeepCopyWith: needs to be updated.  The idea is to catch a change while it is still in the system of the programmer who made it."

	self checkBasicClasses.	"Unlikely, but important to catch when it does happen."

	"Every class that implements veryDeepInner: must copy all its inst vars.  Danger is that a user will add a new instance variable and forget to copy it.  So check that the last one is mentioned in the copy method."
	(aClass includesSelector: #veryDeepInner:) ifTrue: [ 
		((aClass compiledMethodAt: #veryDeepInner:) writesField: aClass instSize) ifFalse: [
			aClass instSize > 0 ifTrue: [
				self warnIverNotCopiedIn: aClass sel: #veryDeepInner:]]].
	(aClass includesSelector: #veryDeepCopyWith:) ifTrue: [
		meth := aClass compiledMethodAt: #veryDeepCopyWith:.
		(meth size > 20) & (meth hasLiteral: #veryDeepCopyWith:) not ifTrue: [
			(meth writesField: aClass instSize) ifFalse: [
				self warnIverNotCopiedIn: aClass sel: #veryDeepCopyWith:]]].

]

{ #category : #'like fullCopy' }
DeepCopier >> checkDeep [
	"Write exceptions in the Transcript.  Every class that implements veryDeepInner: must copy all its inst vars.  Danger is that a user will add a new instance variable and forget to copy it.  This check is only run by hand once in a while to make sure nothing was forgotten.  
(Please do not remove this method.)
	DeepCopier new checkDeep 	"

	Transcript
		cr;
		show: 'Instance variables shared with the original object when it is copied'.
	(self systemNavigation allClassesImplementing: #veryDeepInner:) do: 
			[:aClass | 
			| mm |
			(mm := aClass instVarNames size) > 0 
				ifTrue: 
					[aClass instSize - mm + 1 to: aClass instSize
						do: 
							[:index | 
							((aClass compiledMethodAt: #veryDeepInner:) writesField: index) 
								ifFalse: 
									[Transcript
										cr;
										show: aClass name;
										space;
										show: (aClass allInstVarNames at: index)]]]]
]

{ #category : #'like fullCopy' }
DeepCopier >> checkVariables [
	"Check that no indexes of instance vars have changed in certain classes.  If you get an error in this method, an implementation of veryDeepCopyWith: needs to be updated.  The idea is to catch a change while it is still in the system of the programmer who made it.  
	DeepCopier new checkVariables	"

	self checkBasicClasses.

	"Every class that implements veryDeepInner: must copy all its inst vars.  Danger is that a user will add a new instance variable and forget to copy it.  So check that the last one is mentioned in the copy method."
	(self systemNavigation allClassesImplementing: #veryDeepInner:) do: 
			[:aClass | 
			((aClass compiledMethodAt: #veryDeepInner:) writesField: aClass instSize) 
				ifFalse: 
					[aClass instSize > 0 
						ifTrue: [self warnIverNotCopiedIn: aClass sel: #veryDeepInner:]]].
	(self systemNavigation allClassesImplementing: #veryDeepCopyWith:) do: 
			[:aClass | 
			| meth |
			meth := aClass compiledMethodAt: #veryDeepCopyWith:.
			meth size > 20 & (meth hasLiteral: #veryDeepCopyWith:) not 
				ifTrue: 
					[(meth writesField: aClass instSize) 
						ifFalse: [self warnIverNotCopiedIn: aClass sel: #veryDeepCopyWith:]]]
]

{ #category : #'like fullCopy' }
DeepCopier >> fixDependents [
	"They are not used much, but need to be right"

	DependentsFields associationsDo: [:pair |
		pair value do: [ :dependent | 
			(references at: dependent ifAbsent: nil) ifNotNil: [ :newDependent |
				(references at: pair key ifAbsent: [ pair key ])
					addDependent: newDependent ] ] ]
]

{ #category : #'like fullCopy' }
DeepCopier >> initialize [

	self initialize: 4096.

]

{ #category : #'like fullCopy' }
DeepCopier >> initialize: size [

	references := IdentityDictionary new: size.
	uniClasses := IdentityDictionary new.	"UniClass -> new UniClass"
	"self isItTimeToCheckVariables ifTrue: [self checkVariables]."
		"no more checking at runtime"
	newUniClasses := true.
]

{ #category : #'like fullCopy' }
DeepCopier >> mapUniClasses [
	"For new Uniclasses, map their class vars to the new objects.  And their additional class instance vars.  (scripts slotInfo) and cross references like (player321)."
	"Players also refer to each other using associations in the References dictionary.  Search the methods of our Players for those.  Make new entries in References and point to them."
	| pp |

	newUniClasses ifFalse: [^ self].	"All will be siblings.  uniClasses is empty"
"Uniclasses use class vars to hold onto siblings who are referred to in code"
pp := (Smalltalk at: #Player ifAbsent:[^self]) class superclass instSize.
uniClasses do: [:playersClass | "values = new ones"
	playersClass classPool associationsDo: [:assoc |
		assoc value: (assoc value veryDeepCopyWith: self)].
	playersClass scripts: (playersClass privateScripts veryDeepCopyWith: self).	"pp+1"
	"(pp+2) slotInfo was deepCopied in copyUniClass and that's all it needs"
	pp+3 to: playersClass class instSize do: [:ii | 
		playersClass instVarAt: ii put: 
			((playersClass instVarAt: ii) veryDeepCopyWith: self)].
	].

"Make new entries in References and point to them."
References keys "copy" do: [:playerName | | oldPlayer newKey |
	oldPlayer := References at: playerName.
	(references includesKey: oldPlayer) ifTrue: [
		newKey := (references at: oldPlayer) "new player" uniqueNameForReference.
		"now installed in References"
		(references at: oldPlayer) renameTo: newKey]].
uniClasses "values" do: [:newClass | | newSelList oldSelList |
	oldSelList := OrderedCollection new.   newSelList := OrderedCollection new.
	newClass selectorsAndMethodsDo: [:sel :m | 
		m literals do: [:assoc | | newAssoc newKey |
			assoc isVariableBinding ifTrue: [
				(References associationAt: assoc key ifAbsent: [nil]) == assoc ifTrue: [
					newKey := (references at: assoc value ifAbsent: [assoc value]) 
									externalName asSymbol.
					(assoc key ~= newKey) & (References includesKey: newKey) ifTrue: [
						newAssoc := References associationAt: newKey.
						newClass methodDictionary at: sel put: 
							(newClass compiledMethodAt: sel) shallowCopy.	"were sharing it"
						(newClass compiledMethodAt: sel)
							literalAt: ((newClass compiledMethodAt: sel) literals indexOf: assoc)
							put: newAssoc.
						(oldSelList includes: assoc key) ifFalse: [
							oldSelList add: assoc key.  newSelList add: newKey]]]]]].
	oldSelList with: newSelList do: [:old :new |
			newClass replaceSilently: old to: new]].	"This is text replacement and can be wrong"
]

{ #category : #'like fullCopy' }
DeepCopier >> newUniClasses [
	"If false, all new Players are merely siblings of the old players"

	^ newUniClasses
]

{ #category : #'like fullCopy' }
DeepCopier >> newUniClasses: newVal [
	"If false, all new players are merely siblings of the old players"

	newUniClasses := newVal
]

{ #category : #'like fullCopy' }
DeepCopier >> objInMemory: ClassSymbol [
	| cls |
	"Test if this global is in memory and return it if so."

	cls := Smalltalk at: ClassSymbol ifAbsent: [^ nil].
	^ cls isInMemory ifTrue: [cls] ifFalse: [nil].
]

{ #category : #'like fullCopy' }
DeepCopier >> references [
	^ references
]

{ #category : #'like fullCopy' }
DeepCopier >> uniClasses [
	^uniClasses
]

{ #category : #'like fullCopy' }
DeepCopier >> warnIverNotCopiedIn: aClass sel: sel [
	"Warn the user to update veryDeepCopyWith: or veryDeepInner:"

	self inform: ('An instance variable was added to to class ', aClass name, ',\and it is not copied in the method ', sel, '.\Please rewrite it to handle all instance variables.\See DeepCopier class comment.') withCRs.
	ToolSet browse: aClass selector: sel
]
