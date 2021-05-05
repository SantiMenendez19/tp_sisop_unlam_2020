#include <iostream>
#include <cstring>
#include <cstdlib>
#include <cerrno>
#include <cstdio>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>

using namespace std;

void recFork(int n, int p)
{
	if(n > 0)
	{
		pid_t pid = fork();
		if(pid)
		{
			recFork(n-1,p+1);
			cout << "P" << p << " (" << pid << ") ";					
		}
	}
}


int main ()
{	
	int n;
	cout << endl;
	cout << "Dado el siguiente grafo de jerarquia de procesos, ingrese un numero\nmayor a 0 para generar N jerarquias de procesos hijos adicionales" << endl << endl;
	cout << "   0" << endl;
	cout << " / | \\" << endl;
	cout << "1  2  3" << endl;
	cout << "  /|  |" << endl;
	cout << " 4 5  6" << endl;
	cout << "  \\" << endl;
	cout << "   7" << endl;
	cout << endl;
	
	cout << "Ingrese un numero mayor a 0: ";
	while(!(cin >> n) || n <= 0)
	{
		cout << "ERROR: por favor ingrese un numero mayor a 0: ";
		cin.clear();
		cin.ignore(123, '\n');		
	}	
	
	pid_t pid_ini = getpid();
	pid_t pid1 = fork();	
	pid_t pid2;
	pid_t pid3;
	pid_t pid4;
	pid_t pid5;
	pid_t pid6;
	pid_t pid7;
	
	if(pid1)
	{
		cout << "P1 (" << pid1 << ") ";
	}
	
	else
	{	
		pid2 = fork();
		
		if(pid2)
		{		
			pid5 = fork();	
			
			if(pid5)
			{
				cout << "P5 (" << pid5 << ") ";
			}
			else
			{
				
				pid4 = fork();
				
				if(pid4)
				{
					
					pid7 = fork();
					
					if(pid7)
					{
						recFork(n,8);
						cout << "P7 (" << pid7 << ") ";
					}
					cout << "P4 (" << pid4 << ") ";
				}
			}			
			cout << "P2 (" << pid2 << ") " ;	
		}
		
		else
		{
			pid3 = fork();
			
			if(pid3)
			{
				pid6 = fork();
				
				if(pid6)
				{
					cout << "P6 (" << pid6 << ") ";
				}
				cout << "P3 (" << pid3 << ") " ;				

			}
		}
	}
	
	cout << "P0 (" << pid_ini << ")" << endl;
	return 0;
}

/*

int main () {
	static const int PROC = 5;		// PROC fija la cantidad de procesos a crear

	int status, procNum;			// procNum almacena el número del proceso
	pid_t pid;

	for (procNum=0; procNum<PROC; procNum++) {
		pid = fork();				// se hace fork()
		if (pid==0) {				// si el proceso se crea bien, terminamos el ciclo for
			break;
		}
		else if (pid==-1) {			// si hay error, se aborta la operación
			perror("ERROR al hacer fork()");
			exit(1);
			break;
		}
	}

	if (pid==0) {			// Lógica del Hijo
		cout << "soy el proceso " << procNum << " " << getpid() << " y mi padre es " << getppid() << endl;
		exit(0);
	}
	else {					// Lógica del Padre
	int wpid;
		for (int i=0; i<PROC; i++) {		// esperamos a que todos los hijos terminen (código mejorado)
    		if ((wpid = wait(NULL)) >= 0) {
    			cout << "Proceso " << wpid << " terminado" << endl;
    		}
    	}

		cout << "Soy el padre " << getpid() << endl;
	}

	return 0;		// Fin del programa
}

*/