# CS323 Project Phase2

**12011619 Liquan Wang**

**12111744 Wenhui Tao**

**12111611 Ruixiang Jiang**



## Run

```shell
> make splc #compile the splc compiler for SPL language
> make clean #clean the directory
```


## Design
- Using class `rec` as a node, there are types var, fun, arr, etc., and actions usfun, usassign, etc
- Create initial node in lex
- In Bison, define first, obtain a global map, link the desired elements on the nodes of all action types and then judge the action type of each node


## Traverse Parse Tree
- When DFS traverse the tree, the node of the action type is assigned a value of the corresponding type, which is convenient for use in nested calls later
- In the `recs` of `rec`, for the array will store the value related to its size, the number of values represents the number of dimensions, for `Exp` expression we will store the result of the operation in the val property of rec, for return will look for a specific statement, get its val


## Bonus
- Tests for undefined variables are performed
- The processing of arrays will help us to check the array overreach
