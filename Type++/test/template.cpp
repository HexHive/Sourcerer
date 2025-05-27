#include <type_traits>
class A 
{
};
class AA
{
  char c[9];
};

class BB;
template <typename TemplateType> struct E
{
    struct yes_type { char c[1]; };
    struct no_type  { char c[2]; };

    static yes_type func2 (BB *);

    static no_type func2 (...);

    static_assert(sizeof(AA) == 16, "First"); // VType size == 16
    static_assert(sizeof(yes_type) == 1, "First"); // VType size == 16
    static_assert(sizeof(func2((TemplateType*)0)) == 2, "Second"); // VType size == 16
    static const bool value = (sizeof(func2((TemplateType*)0)) == sizeof(yes_type));
    //static const bool value = std::is_same<BB, TemplateType>::value;
};

template <bool b> struct BOOL {};
class C 
{
    template <typename TemplateType> void func(TemplateType &obj) 
    {
      func(obj, BOOL<E<TemplateType>::value>());
    }
    template <typename TemplateType> void func (TemplateType &obj, BOOL<false>) ;
    template <typename TemplateType> void func (TemplateType &obj, BOOL<true>) 
    {
      int x = obj.why();
    }

};

template void C::func<A> (A &) ;


