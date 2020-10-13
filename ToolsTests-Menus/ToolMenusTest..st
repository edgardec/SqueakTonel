Class {
	#name : #ToolMenusTest,
	#superclass : #TestCase,
	#category : #'ToolsTests-Menus'
}

{ #category : #tests }
ToolMenusTest >> testCodePaneMenu [
	"Checks whether all menu actions are implemented in either the model or the widget."

	| builder builderSelector menuSelector result |
	builder := ToolBuilder default.
	builderSelector := #buildCodePaneWith:.
	menuSelector := #menu.
	result := Dictionary new.

	Model withAllSubclasses
		select: [:modelClass | modelClass includesSelector: builderSelector]
		thenDo: [:modelClass |
			| model spec widget menu selectors |
			result at: modelClass put: OrderedCollection new.
			model := modelClass new.
			spec := model perform: builderSelector with: builder.
			(spec respondsTo: menuSelector) ifFalse: [
				"Little hack to allow code panes being wrapped in panels."
				spec := spec children detect: [:child |
					(child respondsTo: menuSelector) and: [(child perform: menuSelector) notNil]]].
			[widget := builder build: spec] on: Error do: [:ex | ex resume: nil].
			#(false true) do: [:shifted |
				menu := builder build: (builder pluggableMenuSpec new items; yourself).
				menu := model perform: spec menu withEnoughArguments: {menu. shifted}.	
				selectors := menu items collect: [:item | item selector].
				"MVC: selectors := menu selections select: [:sel | sel isSymbol]"
				(result at: modelClass)
					addAll: (selectors reject: [:selector |
						(model respondsTo: selector) or: [widget respondsTo: selector]])]].

	self assert: (result values allSatisfy: [:notImplementedSelectors | notImplementedSelectors isEmpty]).
]
