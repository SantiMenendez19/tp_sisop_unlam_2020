#include <iostream>
#include <thread>

using namespace std;

int *vecFibonacci = {};
int *vecSumas = {};
int vecRes[] = {0,1};
int *tam = new int[1];
int *cont = new int[1];
thread *threads;


void calcularFibonacci(int n)
{	
	if( n <= 0)
	{
		cout << "'" << n << "' es menor o igual que 0\n";
		return;
	}
	*tam = n;
	vecFibonacci = new int[n];
	vecSumas = new int[n];
	int i;		
	vecFibonacci[0] = 1;	
	if( n >= 2 )
	{
		vecFibonacci[1] = 1;
	}	
	for(i = 2; i < n; i++)
	{
		vecFibonacci[i] = vecFibonacci[i-1] + vecFibonacci[i-2];
	}
}

void calcularSuma()
{
	int i;
	for(i = 0; i < *tam; i++)
	{
		vecRes[0] += vecSumas[i];
	}
}

void calcularProd()
{
	int i;
	for(i = 0; i < *tam; i++)
	{
		vecRes[1] *= vecSumas[i];
	}
	
}

void calcularFibAcum(int n)
{
	int i;
	int x = 0;
	for(i = 0; i < n; i++)
	{
		x += vecFibonacci[i];
	}
	
	vecSumas[n-1] = x;
}

class HiloFibonacci
{
	
	public:
		HiloFibonacci(int n)
		{
			threads[*tam-n] = thread(calcularFibAcum, n);
		}
	
};

int main()
{
	cout << endl;
	cout << "Este script recibe un numero entero positivo (mayor a 0)" << endl;
	cout << "Con ese numero, genera N hilos que cada uno calcula\nla sumatoria los primeros n numeros de la sucesion de fibonacci," << endl;
	cout << "almacenando cada resultado en un array de N posiciones" << endl;
	cout << "El resultado final es el producto de todos los elemntos del array,\nmenos la suma de todos los elementos del array" << endl;
	cout << endl;
	*cont = 1;
	int num;
	
	cout << "Ingrese un numero mayor a 0: ";
	while(!(cin >> num) || num <= 0)
	{
		cout << "ERROR: por favor ingrese un numero mayor a 0: ";
		cin.clear();
		cin.ignore(123, '\n');		
	}
	
	calcularFibonacci(num);
	int i;	
	
	threads = new thread[num];
	
	for(i = (num); i > 0; i--)
	{
		new HiloFibonacci(i);
	}
	
	for(i = 0; i < num; i++)
	{
		threads[i].join();
	}
	
	thread threadSuma(calcularSuma);
	thread threadProd(calcularProd);
	
	threadSuma.join();
	threadProd.join();
	
	cout << "Suma: " << vecRes[0] << "\nProducto: " << vecRes[1] << "\n";
	
	cout << "El resultado es " << vecRes[1] - vecRes[0] << "\n";
	
	return 0;
}