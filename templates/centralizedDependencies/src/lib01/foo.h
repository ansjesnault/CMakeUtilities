//header file:
class PublicClass {
public:
    PublicClass();                              // Constructor
    PublicClass(const PublicClass&);            // Copy constructor
    PublicClass(PublicClass&&);                 // Move constructor
    PublicClass& operator=(const PublicClass&); // Copy assignment operator
    ~PublicClass();                             // Destructor
    // Other operations...

private:
    struct CheshireCat;                         // Not defined here
    unique_ptr<CheshireCat> d_ptr;              // opaque pointer
};