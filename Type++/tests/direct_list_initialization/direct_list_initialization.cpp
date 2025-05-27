// Reference : https://en.cppreference.com/w/cpp/language/list_initialization
// Definition : Initializes an object from braced-init-list.

struct Vehicle {
    int wheels;
    int doors;
    double length;

    Vehicle(int w, int d, double l){
        wheels = w;
        doors = d;
        length = l;
    }

    Vehicle() : wheels(0), doors(0), length(0.0) {}
};

class Car : public Vehicle{

    public:

        bool isManual;
        Car() : Vehicle(), isManual(true) {}
        Car(int w, int d, double l, bool m);
};

class Bike : public Vehicle {

    double weight;

    public: 
        Bike(double we, int w, int d, double l) : Vehicle{w,d,l}, weight{we} {}
        Bike(): Vehicle() {}
        
};

Car::Car(int w, int d, double l, bool m) : Vehicle{w,d,l}, isManual{m} {};

int main(){
    // direct list initialization

    Car c1{4, 4, 1.8, true};

    Vehicle* v1 = new Car{c1};
    Vehicle v2 = Car{4, 4, 1.8, true};
    
    Car* c2 = static_cast<Car*>(v1); // Derived handled cast 
    Car* c3 = static_cast<Car*>(&v2); // Derived Type confusion 

    Bike* b1 = new Bike{};
    Car* c4 = static_cast<Car*>((void*)b1); // unrelated type confusion

    delete b1;
}


