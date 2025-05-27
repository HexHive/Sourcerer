# Type confusion encountered in the SPEC CPU benchmarks

## Povray
Issues arise from `Pigment_Struct` and `Tnormal_Struct` that are used as if they
were inheriting from `PaternStruct`.  This is evident from the code snippet
below:

```cpp
struct Pattern_Struct
{
  TPATTERN_FIELDS
};

struct Pigment_Struct
{
  TPATTERN_FIELDS
  COLOUR Colour; 
};

struct Tnormal_Struct
{
  TPATTERN_FIELDS
  SNGL Amount;
  SNGL Delta; /* NK delta */
};
```
This could lead to a type confusion vulnerability if the compiler choose to
arrange differently between `Pigment_Struct` and `Pattern_Struct` the fields
`typedef`ed in `TPATTERN_FIELDS`.  This issue is present both in version 2006
and 2017. The type confusion locations triggered partly differ between versions.


Interestingly, Povray in SPEC CPU 2017 still has the same issue despite the
class hierachy being fixed since 2012 in the main repository. SPEC CPU 2017
seems to rely on a different version that what is noted in its documentation. We
were not able to find the commmit fixing this issue since they changed code
versioning system around then. We can therefore not be sure if the fix was part
of code modernization effort or due to the type confusion.
  
The fix put in place is indeed to have a proper class hierarchy inheriting from
`Pattern_Struct` as shown below:

```cpp
struct Pigment_Struct final : public Pattern_Struct
{
    std::shared_ptr<GenericPigmentBlendMap> Blend_Map;
    TransColour colour;       // may have a filter/transmit component
    ...
};
```

## Apache Xalan-C++
The type confusions found are the same as the ones found by HexType [1]. We
refer to the appendix of their paper for more details.

[1] https://dl.acm.org/doi/pdf/10.1145/3133956.3134062

## Parest
The type confusion occurs in the code included in libc++ as part of the `__tree`
implementation. A fix breaking the ABI is available under the flag
`LIBCXX_ABI_UNSTABLE` or `_LIBCPP_ABI_TREE_REMOVE_NODE_POINTER_UB`. More info
available in the discussion [of this
patch](https://reviews.llvm.org/D20786?id=63267).

## Blender
Similarly to Povray, Blender cast between `VBVHTree` and `RayObject` as
`RayObject` is the first field of `VBVHTree`. This mimicks inheritance and could
be a source of type confusion if the compiler rearrange the order of the fields
in `VBVHTree`.

```cpp
struct VBVHTree {
	RayObject rayobj;
 	VBVHNode *root;
 	MemArena *node_arena;
 	float cost;
  ...
}
```
The code was heavily modernized and does not rely anymore on such *fake
inheritance*. 

## OMNet++
