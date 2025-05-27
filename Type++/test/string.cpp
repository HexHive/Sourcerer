#include <string>

std::string get() {
    if(1 == 0) {
        return "haha"; // just here to avoid optimizng return and hihi
    }
    std::string res = "AAAAAAAA";
    return res;
}

int main(void) {
    std::string s = get();
	printf("%s\n", s.c_str());
}