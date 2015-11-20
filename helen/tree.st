#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: tree.st,v 1.10 2012-02-23 18:57:51-08 - - $"

nl := Character nl.

Object subclass: BitStream [
   |bitIndex byte myStream|
   BitStream class >> new: fileStream [
      |result|
      result := super new.
      result init: fileStream.
      ^result
   ]
   init: fileStream [
      myStream := fileStream.
      bitIndex := 1.
   ]
   nextBit [
      bitIndex = 1 ifTrue: [
         byte := myStream next.
         bitIndex := 9.
      ].
      bitIndex := bitIndex - 1.
      ^byte value bitAt: (9-bitIndex)
   ]
   atEnd [
      ^bitIndex = 1 and: [myStream atEnd]
   ]
]


Object subclass: Leaf [
   |char count|
   char [ ^ char ]
   count [ ^ count ]
   isLeaf [ ^ true ]

   Leaf class >> new [
      self shouldNotImplement
   ]

   Leaf class >> new: aChar count: aCount [
      |result|
      result := super new.
      result setChar: aChar andCount: aCount.
      ^result
   ]

   setChar: aChar andCount: aCount [
      char := aChar.
      count := aCount.
   ]

   <= other [
      ^ (count < other count)
      | ((count = other count) & (char <= other char))
   ]

   printBase: aStream [
      "^ aStream << self class << '(' << char << ',' << count"
      ^ aStream <<char 
  ]

   printOn: aStream [
     " (self printBase: aStream) << ')'."
      (self printBase: aStream).
   ]

   inorder: visitor prefix: string [
      visitor value: char value: string.
   ]

  postorder: visitor prefix: string [
      visitor value: char value: string.
   ]
]


Leaf subclass: Tree [
   |left right achar isLeaf |
    achar [ ^ achar ]  

   Tree class >> new: aChar count: aCount [
      self shouldNotImplement
   ]

   Tree class >> new: aChar count: aCount left: aLeft right: aRight [
      |result|
      result := super new: aChar count: aCount.
      result setLeft: aLeft andRight: aRight andchar: aChar.
      ^ result
   ]

   setLeft: aLeft andRight: aRight andchar: aChar [
      left := aLeft.
      right := aRight.
      achar := aChar.
   ]
   
  isLeaf [ ^ false ] 

   printOn: aStream [
      (self printBase: aStream) << ',' << left << ',' << right << ')'.
   ]

   inorder: visitor prefix: string [
      left inorder: visitor prefix: string, '0'.
      right inorder: visitor prefix: string, '1'.
   ]

   postorder: visitor prefix: string [
      left  postorder: visitor prefix: string, '0'.
      right postorder: visitor prefix: string, '1'.
             
            stdout <<' 1 ' "<<achar <<''" . 
  ]
]


a := Leaf new: $a count: 10.
b := Leaf new: $b count: 20.
c := Leaf new: $c count: 15.
t := Tree new: $t count: 30 left: a right: b.
u := Tree new: $u count: 50 left: t right: c.
x := Leaf new: $x count: 20.
z := Tree new: $z count: 80 left: u right: x.

sortcol := SortedCollection new.
sortcol add: t; add: u; add: a; add: b; add: x; add: z; inspect.



stdout << nl << 'Before remove loop.' << nl.
[sortcol size >1 ] whileTrue: [
   |first|
   first := sortcol removeFirst.
   "stdout << first << nl."
].

atree := sortcol removeFirst.

stdout << nl << 'Before vising z Tree' << nl.
atree postorder: [:char :string |
   stdout << ' 0 ' << char .
] prefix: ''. 

"TEST: tree.st"

