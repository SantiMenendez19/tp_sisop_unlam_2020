#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <string.h>

//Fuentes de ayuda de algunos temas
//https://www.it-swarm.dev/es/c/como-activar-sigusr1-y-sigusr2/972854448/
//https://www.lawebdelprogramador.com/foros/C-Visual-C/1629389-Crear-un-proceso-y-3-hijos.html
//http://sopa.dis.ulpgc.es/ii-dso/leclinux/procesos/fork/LEC7_FORK.pdf
//http://sopa.dis.ulpgc.es/prog_c/PROCES.HTM
//http://manpages.ubuntu.com/manpages/bionic/es/man2/wait.2.html

// Variables globales, solo los PID
pid_t pid_registro;
pid_t pid_control;

// Estructuras de registros
typedef struct
{
    char nombre[20];
    int pid;
    double cpu;
    double memoria;
} t_registro;

typedef struct
{
    int pid;
    char nombre[20];
    char exceso[20];
    char hora[10];
} t_registro_buffer;

// Funciones
void help()
{
    printf("Deben ir los parametros de la siguiente forma:\n");
    printf("./ejercicio_4 $limite_cpu $limite_memoria\n");
    printf("Parametros obligatorios:\n");
    printf("limite_cpu: Porcentaje limite del cpu positivo y menor a 99\n");
    printf("limite_memoria: Porcentaje limite de la memoria positivo y menor a 99\n");
}

void kill_child_process(int sig)
{
    kill(pid_registro, SIGTERM);
    kill(pid_control, SIGTERM);
    printf("Matando procesos...\n");
    sleep(5);
    printf("Termino el proceso Principal junto con Control y Registro\n");
    exit(0);
}

void obtener_hora_sistema(char *hora)
{
    time_t tiempo = time(0);
    struct tm *tlocal = localtime(&tiempo);
    strftime(hora, 128, "%H:%M:%S", tlocal);
}

void proceso_control(double limite_cpu, double limite_memoria)
{
    printf("Proceso Control iniciado PID: %d \n", getpid());
    //printf("%lf %lf", limite_cpu, limite_memoria);
    int fd;
    FILE *fp_ps;
    t_registro reg;
    char buffer[100];
    char linea[100];
    char hora[15];
    while (1)
    {
        time_t tiempo = time(0);
        struct tm *tlocal = localtime(&tiempo);
        strftime(hora, 128, "%H:%M:%S", tlocal);
        fp_ps = popen("/bin/ps -axo user,pid,pcpu,pmem --no-headers", "r");
        while (fgets(linea, sizeof(linea), fp_ps) != NULL)
        {
            sscanf(linea, "%s %d %lf %lf", reg.nombre, &reg.pid, &reg.cpu, &reg.memoria);
            //printf("%s %d %lf %lf\n",reg.nombre, reg.pid, reg.cpu, reg.memoria);
            if (limite_cpu - reg.cpu < 0 && limite_memoria - reg.memoria < 0)
            {
                sprintf(buffer, "%d %s %s %s", reg.pid, reg.nombre, "Ambos", hora);
                fd = open("tmp/fifo_registros", O_WRONLY);
                write(fd, buffer, sizeof(buffer));
            }
            else if (limite_cpu - reg.cpu < 0)
            {
                sprintf(buffer, "%d %s %s %s", reg.pid, reg.nombre, "CPU", hora);
                fd = open("tmp/fifo_registros", O_WRONLY);
                write(fd, buffer, sizeof(buffer));
            }
            else if (limite_memoria - reg.memoria < 0)
            {
                sprintf(buffer, "%d %s %s %s", reg.pid, reg.nombre, "Memoria", hora);
                fd = open("tmp/fifo_registros", O_WRONLY);
                write(fd, buffer, sizeof(buffer));
            }
        }
        pclose(fp_ps);
        sleep(1);
    }
    close(fd);
    exit(0);
}

void proceso_registro()
{
    printf("Proceso Registro iniciado PID: %d \n", getpid());
    int fd;
    int num_bytes;
    FILE *fp;
    t_registro_buffer reg;
    char buffer[100];
    char linea[100];
    char exceso_archivo[15], exceso_old[15];
    int count_pid;
    int pid_proceso_archivo;
    fd = open("tmp/fifo_registros", O_RDONLY);
    while (1)
    {
        pid_proceso_archivo = 0;
        count_pid = 0;
        num_bytes = read(fd, buffer, sizeof(buffer));
        if (num_bytes > 0)
        {
            sscanf(buffer, "%d %s %s %s", &reg.pid, reg.nombre, reg.exceso, reg.hora);
            fp = fopen("registros.txt", "rt");
            if (fp)
            {
                while (fgets(linea, sizeof(linea), fp) != NULL)
                {
                    sscanf(linea, "%d: Supera %s ", &pid_proceso_archivo, exceso_archivo);
                    if (reg.pid == pid_proceso_archivo)
                    {
                        count_pid++;
                        strcpy(exceso_old, exceso_archivo);
                        //printf("%d %d %s %s\n", reg.pid, pid_proceso_archivo, exceso_old, reg.exceso);
                    }
                }
                fclose(fp);
            }
            fp = fopen("registros.txt", "at");
            if (count_pid == 0)
            {
                fprintf(fp, "%d: Supera %s %s\n", reg.pid, reg.exceso, reg.hora);
            }
            else if (strcmp(exceso_old, "Ambos") != 0)
            {
                if (strcmp(exceso_old, reg.exceso) != 0)
                {
                    fprintf(fp, "%d: Supera %s o Ambos %s\n", reg.pid, reg.exceso, reg.hora);
                }
            }
            fclose(fp);
        }
    }
    close(fd);
    exit(0);
}

int main(int argc, char *argv[])
{
    //Validacion de parametros
    if (argc < 3)
    {
        printf("Error, deben haber dos parametros\n");
        help();
        exit(1);
    }
    double limite_cpu = atof(argv[1]);
    double limite_memoria = atof(argv[2]);
    printf("Limite CPU: %lf Limite Memoria: %lf\n", limite_cpu, limite_memoria);
    if (limite_cpu < 0 || limite_memoria < 0 || limite_cpu > 99 || limite_memoria > 99)
    {
        printf("Error, uno de los parametros pasados es negativo o supera el 99\n");
        help();
        exit(1);
    }
    //Creacion del FIFO
    mkfifo("tmp/fifo_registros", 0666);
    //Fork de los procesos hijos Control y Registro
    pid_registro = fork();
    if (!pid_registro)
    {
        // Proceso Control
        proceso_control(limite_cpu, limite_memoria);
    }
    pid_control = fork();
    if (!pid_control)
    {
        // Proceso Registro
        proceso_registro();
    }
    // Proceso principal
    printf("Proceso Padre iniciado PID: %d \n", getpid());
    printf("A la espera de la señal SIGUSR1\n");
    // Espera la señal y despues mata los procesos
    signal(SIGUSR1, kill_child_process);
    while (1)
    {
    }
    return 0;
}
