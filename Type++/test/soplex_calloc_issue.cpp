#include <iostream>
#include <stdlib.h> /* malloc, free, rand */

class SVector
{
};
template <class T>
inline void spx_alloc(T &p, int n)
{
   p = reinterpret_cast<T>(malloc(sizeof(*p) * n));
}
template <class T>
inline void spx_realloc(T& p, int n)
{
   p = reinterpret_cast<T>(realloc(p, sizeof(*p) * n));
}

class DataKey
{
protected:
public:
   signed int info : 8;                    ///< user information (8 bit)
   signed int idx : (8 * sizeof(int) - 8); ///< (locally) unique key index

public:
   DataKey()
       : info(0), idx(-1)
   {
   }

   // Constructor
   DataKey(int p_info, int p_idx)
       : info(p_info), idx(p_idx)
   {
   }
};


template < class T >
class IsList
{
protected:
   T* the_first;   ///< the first element in the #IsList.
   T* the_last;    ///< the last element in the #IsList.

public:
   T* first() const
   {
      return the_first;
   }

   /// returns the #IsList's last element.
   T* last() const
   {
      return the_last;
   }

   void move(ptrdiff_t delta)
   {
         T* elem;
         the_last  = reinterpret_cast<T*>(reinterpret_cast<char*>(the_last) + delta);
         the_first = reinterpret_cast<T*>(reinterpret_cast<char*>(the_first) + delta);
   }

   IsList(T* pfirst = 0, T* plast = 0)
      : the_first(pfirst), the_last(plast)
   {
   }
   //@}
};

template < class T >
class IdList : public IsList<T>
{
public:
   void move(ptrdiff_t delta)
   {
         T* elem;
         IsList<T>::move(delta);
   }
   IdList(T* pfirst = 0, T* plast = 0)
      : IsList<T>(pfirst, plast)
   {}


};
template <class DATA>
class DataSet
{
public:
   struct Item
   {
      DATA data; ///< data element
      int info;  ///< element number. info \f$\in\f$ [0,thesize-1]
                 ///< iff element is used
   } * theitem;  ///< array of elements in the #DataSet

   DataKey *thekey; ///< #DataKey::idx%s of elements
   int themax;      ///< length of arrays #theitem and #thekey
   int thesize;     ///< highest used element in #theitem
   int thenum;      ///< number of elements in #DataSet
   int firstfree;   ///< first unused element in #theitem
public:
   DataSet(int pmax = 8)
       : theitem(0), thekey(0), themax(pmax < 1 ? 8 : pmax), thesize(0), thenum(0)
   {

      spx_alloc(theitem, themax);
      spx_alloc(thekey, themax);
   }

   ptrdiff_t reMax(int newmax = 0)
   {
      struct Item * old_theitem = theitem;

      int* lastfree = &firstfree;
      *lastfree = -newmax - 1;

      themax = newmax;

      spx_realloc(theitem, themax);
      spx_realloc(thekey,  themax);

      return reinterpret_cast<char*>(theitem) 
         - reinterpret_cast<char*>(old_theitem);
   }
};
class SVSet
{
public:
   class DLPSV : public SVector
   {
   public:
      DLPSV *thenext; ///< previous SVector
      DLPSV *theprev; ///< next SVector

   public:
      /// default constructor.
      DLPSV() : SVector()
      {
      }
      /// copy constructor.
      DLPSV(const DLPSV &copy) : SVector(copy)
      {
      }
   };
   DataSet<DLPSV> set; ///< %set of SVectors
      IdList < DLPSV > list;  ///< doubly linked list for non-zero management

public:
   SVSet(int pmax = 1)
       : set((pmax > 0) ? pmax : 8)
   {
      for (int i = 0; i < pmax; i++)
      {
         DLPSV *d = new DLPSV();

      }
   }
void reMax(int newmax)
{
   DLPSV* d = new DLPSV();
   list.move(set.reMax(newmax));
}

   void ensurePSVec()
   {
      reMax(8);
   }
};

int main(void)
{
   std::cout << "hll\n";

   SVSet s = SVSet();
   s.ensurePSVec();
   return 0;
}