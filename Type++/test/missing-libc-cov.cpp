#include <memory>

_LIBCPP_BEGIN_NAMESPACE_STD
template <class _Tp, class _Allocator> class __tree;


template <class T> class Side {
public:
    T __left_;
    Side() : __left_() {}
};

template <class _VoidPtr>
class Parent{ };

template <class _Tp, class _VoidPtr>
class Child : public Parent<_VoidPtr> { };


template <class T, class X>
struct __tree_node_types;

template <class _NodePtr, class _Tp, class _VoidPtr>
struct __tree_node_types<_NodePtr, Child<_Tp, _VoidPtr> >
{
  typedef _NodePtr                                              __node_pointer;
  typedef Parent<_VoidPtr>                      __node_base_type;
  typedef typename __rebind_pointer<_VoidPtr, __node_base_type>::type
                                                             __node_base_pointer;

  typedef typename __rebind_pointer<_VoidPtr, Side<__node_base_pointer> >::type
                                                              __parent_pointer;
};

struct B {};

template <class _Tp, class _Allocator> class __tree
{
public:
    typedef allocator_traits<_Allocator>         __alloc_traits;
    typedef typename __alloc_traits::void_pointer _VoidPtr;
    typedef typename __rebind_pointer<_VoidPtr, Child<_Tp, _VoidPtr> >::type _NodePtr;
    typedef  __tree_node_types<_NodePtr, typename pointer_traits<_NodePtr>::element_type > _NodeTypes;

    typedef typename __rebind_alloc_helper<__alloc_traits, B>::type __node_allocator;
    typedef allocator_traits<__node_allocator>         __node_traits;

    typedef typename _NodeTypes::__parent_pointer      __parent_pointer;
    typedef typename _NodeTypes::__node_base_pointer   __node_base_pointer;
    typedef typename _NodeTypes::__node_pointer        __node_pointer;
    __tree(){}

    template <class, class, class>  class  map;
};

struct C {};

template <class _Key,  class _Allocator = allocator<_Key> > class  map {
public:
    // types:
    typedef typename __identity<_Allocator>::type    allocator_type;
    typedef typename __rebind_alloc_helper<allocator_traits<allocator_type>, C>::type __allocator_type;
    typedef __tree<C,  __allocator_type>   __base;
    typedef typename __base::__parent_pointer          __parent_pointer;
    typedef typename __base::__node_base_pointer       __node_base_pointer;
    typedef typename __base::__node_pointer            __node_pointer;

    __base __tree_;
    map() : __tree_() {}

    void operator[](_Key& __k)
    {
        __parent_pointer __parent;
        __node_base_pointer& __child = __parent->__left_;
        __node_pointer __r = static_cast<__node_pointer>(__child);
        if (__child == nullptr) {}
    }
};


_LIBCPP_END_NAMESPACE_STD



using std::map;


class JMap {
public:
    map<int> m;
    JMap() : m() {}
    void put(int key) {
        m[key];
    }
};


  
int main(void) {
    JMap g;
    g.put(1);
}