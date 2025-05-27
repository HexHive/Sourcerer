
class D {};

class E : public D {
    int x = 0;
};   


class F : public D{
    float y = 0;
};

int main() {
    D *d = new E();

    E *e = static_cast<E*>(d); // derived handle cast
    delete d;

    d = new F(); // d is reused after delete

    E* e2 = static_cast<E*>(d); // derived type confusion
    return 0;
}