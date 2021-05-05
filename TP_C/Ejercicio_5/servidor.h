#ifndef SERVIDOR_H_INCLUDED
#define SERVIDOR_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <fcntl.h>
#include <semaphore.h>
#include <string.h>


#define TODO_OK         0
#define FALSO           0
#define VERDADERO       1
#define LISTA_VACIA    -1

typedef struct
{
    char nombre[60]
    char presente
} t_asistencia;

typedef struct s_nodo
{
    t_asistencia d;
    struct s_nodo* sig;
} t_nodo;

typedef t_nodo* t_lista;

typedef struct
{
    char nombre[20];
    char contraseña[20];
	char rol;
    int cod_comision;
} t_usuarios;


void crear_lista(t_lista *pl);
int insertar_ordenado(t_lista *pl, t_asistencia* dato);
int sacar_primero(t_lista *pl, t_infra *dato);
int registros_a_suspender(t_lista *pl, t_infractores *dato);
int ingresar_multa(t_infractores *registro);
int cancelar_multa(t_infractores *dato);
int monto_por_patente(t_infractores *dato);
float monto_total(char *partido);
void txt_a_parsear(FILE *txt);
void parseo_txt_var(char * linea,t_usuarios *user);


#endif // SERVIDOR_H_INCLUDED
