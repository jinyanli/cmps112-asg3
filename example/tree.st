#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: tree.st,v 1.10 2012-02-23 18:57:51-08 - - $"

nl := Character nl.

Object subclass: Leaf [
   |char count|
   char [ ^ char ]
   count [ ^ count ]

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
      ^ aStream << self class << '(' << char << ',' << count
   ]

   printOn: aStream [
      (self printBase: aStream) << ')'.
   ]

   inorder: visitor prefix: string [
      visitor value: char value: string.
   ]
   
   postorder: visitor [
      visitor value: char.
   ]
]


Leaf subclass: Tree [
   |left right "char count"|

   Tree class >> new: aChar count: aCount [
      self shouldNotImplement
   ]

   Tree class >> new: aChar count: aCount left: aLeft right: aRight [
      |result|
      result := super new: aChar count: aCount.
 
      result setLeft: aLeft andRight: aRight.
      ^ result
   ]
   "
   treesetChar: aChar andtreeCount: aCount [
      char := aChar.
      count := aCount.
   ]
   "
   setLeft: aLeft andRight: aRight [
      left := aLeft.
      right := aRight.
   ]

   printOn: aStream [
      (self printBase: aStream) << ',' << left << ',' << right << ')'.
   ]
   
   postorder: visitor[
      
      left postorder: visitor .
      right postorder: visitor .  
      visitor value: char.
   ]

   inorder: visitor prefix: string [
      "stdout<<'visitor: '<<visitor <<' string:  '<<string.
      stdout<<' left: '<<(left = nil).
      stdout<<' right: '<<(right = nil)."
      left inorder: visitor prefix: string, '0'.
      right inorder: visitor prefix: string, '1'. 
   ]

   
]


zero := Leaf new: 0 count: 13.
a := Leaf new: 97 count: 10.
b := Leaf new: 98 count: 20.
c := Leaf new: 99 count: 15.
x := Leaf new: 120 count: 20.
eof := Leaf new: 256 count: 1.
t := Tree new: $t count: 30 left: a right: b.
u := Tree new: $u count: 50 left: t right: c.
z := Tree new: $z count: 80 left: u right: x.

"
sortcol := SortedCollection new.
sortcol add: t; add: u; add: a; add: b; add: x; add: z; inspect.
"
treequeue := SortedCollection new.
queue := SortedCollection new.
queue add: a; add: b; add: c; add: x;add: eof;add: zero;inspect.

|decodingtree|
stdout << nl << 'bulid tree.' << nl.
"stdout << nl << '----bulid tree-----' << nl."
[queue size >1 ] whileTrue: [
   |leftchild rightchild|
   
   leftchild := queue removeFirst.
   rightchild := queue removeFirst.
   newtree := ( Tree new: -1
                      count: (leftchild count) +  (rightchild count)
                      left: leftchild right: rightchild).
   queue add: newtree.
].
decodingtree:=queue removeFirst.

stdout << '-----------decoding tree--------------' << nl.
stdout << decodingtree << nl.

stdout << nl << 'inorder vising decoding tree' << nl.
decodingtree inorder: [:char :string |
   stdout << '[' << char << ']=' << string << nl.
] prefix: ''.


stdout << nl << 'postorder traversal decoding tree' << nl.
string:=''.
count:=0.
decodingtree postorder: [:char |
   (char =-1) ifTrue:[string:=string,'[1]'.]
                ifFalse:[
                   bin:=''.
                   char = 256
                        ifTrue:[bin:='000000001']
                        ifFalse:[
                           char=0 ifTrue:[bin:='000000000']
                                  ifFalse:[
                                     8 to:1 by: -1 do:[:i|
                                     bin:=bin,((char bitAt:i) printString).
                                   ]
                        ].
                  
                 ].
                 string:=(string,'[0]','(',bin,')').
              ].
   stdout << '[' << char << ']=' << string <<' count:='<< (count:=count+1) <<nl.
].
stdout <<'tree nodes: '<<string << nl.


"
stdout << nl << 'Before queue do: loop' << nl.
queue do: [:item |
   queue << item << nl.
]."


"
stdout << nl << 'Before vising z Tree' << nl.
z inorder: [:char :string |
   stdout << '[' << char << ']=' << string << nl.
] prefix: ''.

stdout << nl << 'Before sortcol do: loop' << nl.
sortcol do: [:item |
   stdout << item << nl.
].

stdout << nl << 'Before remove loop.' << nl.
[sortcol notEmpty] whileTrue: [
   |first|
   first := sortcol removeFirst.
   stdout << first << nl.
]
"
"TEST: tree.st"

