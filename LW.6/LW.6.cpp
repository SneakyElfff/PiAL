//
//  main.cpp
//  LW.6
//
//  Created by Нина Альхимович on 9.11.22.
//  2. Ввести массив чисел с плавающей точкой на 10 элементов. Вычислить среднее значение элементов массива.

#include <iostream>
#pragma inline
#define n 10

using namespace std;

int main()
{
    int i;
    float *array = new float[n], result;
    
    cout << "Вводите элементы массива: " << endl;
    for(i=0; i<n; i++)
    {
        cout << "array[" << i << "] = ";
        cin >> array[i];
    }
    
    _asm
    {
        xor ecx, ecx
        mov cx, 10
        finit
        mov eax, array
        fld 10
        fld result
        start:
            fadd [eax]
            add eax, 4
            cmp cx, 0
            dec cx
            jnz start

            fdiv st(0),st(1)
            fst result
                
            fwait
    }
    
    cout << "Среднее арифметическое элементов массива: " << result << endl << endl;
    
    delete [] array;
    
    return 0;
}
