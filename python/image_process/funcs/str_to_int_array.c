#include <Python.h>
#include <stdio.h>

void str_to_int_array( const char* raw , PyObject* list_int ) {
    printf( "[+] %u \n" , raw[0] ) ;
    // printf( "[+] %s %d\n" , raw , PyInt_AsLong( PyList_GetItem( list_int , 1 ) ) ) ;
    // PyList_SetItem( list_int , 0 , PyInt_FromLong( 44 ) ) ;
    // PyList_Append( list_int , PyInt_FromLong( i ) ) ;
    // printf( "[+] %d\n" , raw[0] ) ;
    return ;
}