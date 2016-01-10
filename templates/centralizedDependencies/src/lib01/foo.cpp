//CPP file:
#include "PublicClass.h"

struct PublicClass::CheshireCat {
    int a;
    int b;
};

PublicClass::PublicClass()
    : d_ptr(new CheshireCat()) {
    // do nothing
}

PublicClass::PublicClass(const PublicClass& other)
    : d_ptr(new CheshireCat(*other.d_ptr)) {
    // do nothing
}

PublicClass::PublicClass(PublicClass&& other) 
{
    d_ptr = std::move(other.d_ptr);
}

PublicClass& PublicClass::operator=(const PublicClass &other) {
    *d_ptr = *other.d_ptr;
    return *this;
}

PublicClass::~PublicClass() {}