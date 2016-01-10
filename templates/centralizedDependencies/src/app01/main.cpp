#include <iostream>
#ifdef HAS_QT
#include <QApplication>
#endif

#ifndef HAS_QT
#include <glutIbrApp.h>
#include <GLlibs.h>
#endif

int main (int argc, char **argv) {
    try
	{
#ifdef HAS_QT
        QApplication app(argc,argv);
#ifndef HAS_QT
        g_ibr_ptr = &ibr;
		glutInitApp(argc, argv);
#endif

        std::cout << "start the rendering loop" << std::endl;
		
#ifdef HAS_QT
        app.exec();
#else
        glutSetWindowTitle("IBR");
        glutMainLoop();
#endif
        return EXIT_SUCCESS;
    } 
	catch (std::runtime_error& e) 
	{
        std::cerr << std::endl << "Runtime Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
}

