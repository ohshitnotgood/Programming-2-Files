**tree, no param**
- get two node
- return a `:leaf` tuple
- call tree with parameter


**tree with parameter**
- get one node
- if node is larger or equal to param value, 
    - create a brand new tree
    - merge the two trees
- if node is smaller than the param
    - keep generating trees until a tree larger or equal to current is reached
