#include<stdio.h>
#include<fcntl.h>
#include<unistd.h>
#include<string.h>
#include<arpa/inet.h>
#include<sys/socket.h>

int main(){
	
	
	struct sockaddr_in direccionServidor;
	direccionServidor.sin_family= AF_INET;
	direccionServidor.sin_addr.s_addr=INADDR_ANY
	direccionServidor.sin_port=htons(9000)
	
	int servidor=socket(AF_INET,SOCK_STREAM,0);
	
	
	if(bind(servidor,(void*) &direccionServidor, sizeof(direccionServidor))!=0){
		perror("Falló el bind");
		return 1;
	}
	
	printf("estoy escuchando\n");
	listen(servidor,5);
	
	
	FILE * pf = fopen("Usuarios.txt", "r");

    t_usuarios *usuarios;

    if( !pf )
    {
        printf("No se pudo abrir el archivo");
		return 1;
    }
	
	char temp[50]
	int cont =0;
	
	while(  !feof(pf) ){
		fgets(temp,50,pf);
		cont++;
	}
	
	rewind(f);
	
	usuarios = (t_usuarios*)malloc(cont*sizeof(t_usuarios));
	if(usuarios==NULL){
		printf("no hay memoria");
	}
	
	int i=0;
	fscanf(pf,"%[^|],%[^|],%[^|],%d\n", usuarios[i].nombre, usuarios[i].contraseña, usuarios[i].rol, &usuarios[i].cod_comision);
    while(  !feof(pf) )
    {
        fscanf(pf,"%[^|],%[^|],%[^|],%d\n", usuarios[i].nombre, usuarios[i].contraseña, usuarios[i].rol, &usuarios[i].cod_comision);
       i++;
    }
    fclose(pf);
	
	//---------------------
	
	struct sockaddr_in direccionCliente;
	unsigned int tamDireccion;
	int cliente = accept(servidor, (void*)&direccionCliente,&tamDireccion);
	
	printf("Recibi una conexion\n",cliente);
	send(cliente,"Hola",5,0);
	
	//------------------------
	
	char* buffer = malloc(100);
	
	while(1){
		int bytesRecibidos = recv(Cliente, buffer,100, 0);
		if bytesRecibidos<=0){
			perror("se desconectó");
			return 1;
		}
		
		bytesRecibidos[bytesRecibidos]= '\0';
		printf("llegaron %d bytes con %s \n",bytesRecibidos, buffer);
	}
	free(buffer);
	
	close(cliente);
	
	close(servidor);

	return 0;
}


void txt_a_parsear(FILE *txt)
{
    t_usuarios user;
    char linea[TAM];

    fgets(linea,TAM,txt);

    while(!feof(txt))
    {
        parseo_txt_var(linea,&emp);
        fgets(linea,TAM,txt);

    }
}

void parseo_txt_var(char * linea,t_usuarios *user)
{

    char *act = strchr(linea,'\n');

    *act='\0';
    act=strrchr(linea,'|');

	strncpy(user->nombre,act+1,sizeof(user->nombre));

	*act='\0';
    act=strrchr(linea,'|');
	strncpy(user->contraseña,act+1,sizeof(user->contraseña));

	*act='\0';
    act=strrchr(linea,'|');
    user->rol=*(act+1);

    *act='\0';
     sscanf(linea,"%d",&user->cod_comision);
}