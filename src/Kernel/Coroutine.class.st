"
A Coroutine is coroutine.

"
Class {
	#name : #Coroutine,
	#superclass : #Object,
	#instVars : [
		'block',
		'ctx',
		'resume',
		'value',
		'isCompleted'
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

{ #category : #accessing }
Coroutine >> initialize [

	super initialize.

	isCompleted := false.
	resume := CoroutineResume new
		          coroutine: self;
		          yourself
]

{ #category : #clearing }
Coroutine >> reset [

	self swapContext: nil.
	isCompleted := false.
	value := nil
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

	^ self valueIfNotCompleted: [ 
		  ctx
			  ifNil: [ 
				  value := block cull: resume cull: aValue.
				  isCompleted := true.
				  value ]
			  ifNotNil: [ 
				  | lastCtx |
				  lastCtx := self swapContext: nil.
				  thisContext swapSender: lastCtx.
				  aValue ] ]
]

{ #category : #accessing }
Coroutine >> value: aValue resumedByCoroutine: aCoroutine [

	^ self value: aValue
]

{ #category : #accessing }
Coroutine >> valueIfNotCompleted: aBlock [

	^ isCompleted
		  ifTrue: [ value ]
		  ifFalse: aBlock
]
