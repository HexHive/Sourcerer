// caused a sefault due to a null dereference in while loop of our 
// instrumentation CGExprScalar.cpp:2134
#include <immintrin.h>

const __m128 _mm_lookupmask_ps[1] = {
  _mm_castsi128_ps(_mm_set_epi32( 0, 0, 0, 0)),
};
