#!/usr/bin/bash 
#@Modelo base para discador automatico com Asterisk
#by: Samuel Dantas
#Versao 0.1.3

##
#VARIAVEIS REFERENTES AO MAILING
NAME=2        #coluna referente ao nome do cliente no mailing
ID=1          #coluna referente ao id da posicao do cliente
NUMBER=4      #coluna referente ao numero de telefone no mailing
DDD=3         #coluna referente ao ddd do arquivo de mailing
#

##
#VARIAVEIS REFENTES AO CALLFILE
TECNOLOGY="DAHDI/g1"    #aqui pode vir qualquer tecnologia (ex: DAHDI/g1) usar sempre nesse formato sem a ultima barra
PERSIST="5"             #quantidade de vezes que ira chamar o originador antes de falhar a chamada
PERSIST_INTERVAL="60"   #intervalo em segundos entre uma tentativa e outra para chamar o originador 
PERSIST_WAIT="30"       #qauntidade em segundos que o asterisk ira chamar no originador ate considerar falha
CONTEXT="from-pstn"     #contexto do dialplan que o asterisk ira encaminhar as chamadas completadas
EXTENSION="s"           #extensao que ele ira colocar no contexto escolhido, uma dica para grupos/queues eh colocar aqui o ddr equivalente a sua queue/grupo
PRIORITY="1"            #prioridade da extensao no contexto (exten => _XXXX,s,1) no exemplo a prioridade eh o terceiro item
BINA="00000000000"      #seu numero para binar no cliente
MAILING="/home/samuel/teste.txt"
SPOOL_FILE="/home/samuel/testeMailing/"
FILE_DONE="/home/samuel/fileDone.log"
#

case "$1" in 
        start)  #loop para manter o processo rodando
                #while : 
                #do      
                        #FILTRANDO O MAILING PARA TER APENAS ID E TELEFONE COM DDD
                                                                                        #inicio de um novo loop dentro da leitura do mailing
                                                                                        #afim de pegar ddd, numero e id correspondente
                        cat $MAILING | awk -F ';' "{print \$$ID\" \" \$$DDD \$$NUMBER}" | while IFS=' ' read ID_R PHONE ; do 
                                #AQUI ONDE MONTAMOS O ARQUIVO, PODE SER FEITO QUALQUER CONDICAO QUE IRA DAR CARACTERISTICAS AO DIALER
                                #EXEMPLO: PODEMOS VERIFICAR UM MAXIMO DE CANAIS A OCUPAR, OU A QUANDIDADE DE AGENTES LIVRES NA QUEUE
                                #START
                                        DIAL_FILE='/home/samuel/'$(date +"%m%d%y%N")'.call'
                                        #parametros do callFile asterisk:
                                        #aqui montamos o arquivo .call em um temporario para depois mover p/ o spool que ira discar
                                        echo "Channel: ${TECNOLOGY}/${PHONE}"            > ${DIAL_FILE} 
                                        echo "Callerid: <${BINA}> \"TestName\""         >> ${DIAL_FILE}
                                        echo "MaxRetries: ${PERSIST}"                   >> ${DIAL_FILE}
                                        echo "RetryTime: ${PERSIST_INTERVAL}"           >> ${DIAL_FILE}
                                        echo "WaitTime: ${PERSIST_WAIT}"                >> ${DIAL_FILE}
                                        echo "Context: ${CONTEXT}"                      >> ${DIAL_FILE}
                                        echo "Extension: ${EXTENSION}"                  >> ${DIAL_FILE}
                                        echo "Priority: ${PRIORITY}"                    >> ${DIAL_FILE}
                                        #movendo o arquivo que montamos para o spool onde o asterisk ira discar
                                        mv ${DIAL_FILE} ${SPOOL_FILE} #arquivo do spool de discagem
                                        echo "[$(date +"%d-%m-%Y %H:%M:%S")] - ID: $ID_R TELEFONE: $PHONE" >> ${FILE_DONE} #guardando log do que foi gerado callfile
                                        sed -i "/^$ID_R.*/d" ${MAILING}  #suprimindo os numeros ja discados do mailing
                                #END
                        done
                #done & echo $! > .pid &2>>/dev/null&
                ;;
        stop)
                kill -9 `cat .pid`
                ;;
        *)
                echo "Opcoes validas: start|stop"
                exit 1
                ;;
esac



        




                

