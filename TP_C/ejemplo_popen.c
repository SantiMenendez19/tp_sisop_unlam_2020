#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

typedef struct
{
    char nombre[20];
    int pid;
    double cpu;
    double memoria;
} t_registro;

int main()
{
    FILE *fp_ps;
    t_registro reg;
    char delim[] = "  ";
    char path[1035];
    char *ptr;
    fp_ps = popen("/bin/ps -axo user,pid,pcpu,pmem --no-headers", "r");
    while (fgets(path, sizeof(path), fp_ps) != NULL)
    {
        //printf("%s", path);
        sscanf(path,"%s %d %lf %lf",reg.nombre,&reg.pid,&reg.cpu,&reg.memoria);
        printf("%s %d %f %f\n",reg.nombre,reg.pid,reg.cpu,reg.memoria);
        //ptr = strtok(path, delim);
        //while (ptr != NULL)
        //{
        //    printf("'%s'\n", ptr);
        //    ptr = strtok(NULL, delim);
        //}
        //for (int i = 0; i < 4; i++)
        //{
        //    printf("%s ", &path[i]);
        //}
        //printf("\n");
    }
    pclose(fp_ps);
    return 0;
}