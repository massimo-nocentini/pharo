"
A Coroutine is coroutine.

"
Class {
	#name : #Coroutine,
	#superclass : #Object,
	#instVars : [
		'block',
		'ctx'
	],
	#category : #'Kernel-Methods'
}

{ #category : #enumerating }
Coroutine class >> currentDo: aBlock [

	| co main |
	main := nil.

	co := self on: [ :resume :useless | 
		      aBlock value: [ :v | resume value: main value: v ] ].

	main := self on: [ :resume :value | resume value: co value: value ].

	^ main value: nil
]

{ #category : #'instance creation' }
Coroutine class >> on: anObject [

	^ anObject onCoroutine: self new
]

{ #category : #'instance creation' }
Coroutine class >> try: tryBlock otherwise: elseBlock [

	^ self currentDo: [ :success | 
		  | localResult |
		  localResult := self currentDo: [ :local | 
			                 success value: (tryBlock value: local) ].
		  elseBlock cull: localResult ]
]

{ #category : #accessing }
Coroutine >> block: aBlock [

	block := aBlock
]

{ #category : #clearing }
Coroutine >> reset [

	self swapContext: nil
]

{ #category : #accessing }
Coroutine >> swapContext: aContext [

	| old |
	old := ctx.
	ctx := aContext.
	^ old
]

{ #category : #accessing }
Coroutine >> value: aValue [

	^ ctx
		  ifNil: [ 
			  block
				  cull: [ :coroutine :value | 
					  self swapContext: thisContext sender.
					  coroutine value: value resumedByCoroutine: self ]
				  cull: aValue
				  cull: self ]
		  ifNotNil: [ 
			  | lastCtx |
			  lastCtx := self swapContext: nil.
			  thisContext swapSender: lastCtx.
			  aValue ]
]

{ #category : #accessing }
Coroutine >> value: aValue resumedByCoroutine: aCoroutine [

	^ self value: aValue
]
