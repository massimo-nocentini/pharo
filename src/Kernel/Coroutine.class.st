"
A Coroutine is coroutine.

"
Class {
	#name : #Coroutine,
	#superclass : #Object,
	#instVars : [
		'block',
		'ctx',
		'resume'
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

	resume := CoroutineResume new
		          coroutine: self;
		          yourself
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

	^ ctx ifNil: [ block cull: resume cull: aValue ] ifNotNil: [ 
		  | lastCtx |
		  lastCtx := self swapContext: nil.
		  thisContext swapSender: lastCtx.
		  aValue ]
]

{ #category : #accessing }
Coroutine >> value: aValue resumedByCoroutine: aCoroutine [

	^ self value: aValue
]
