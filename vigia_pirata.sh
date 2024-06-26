case "$1" in
  "-p")
    db_path="$HOME/.protecao"
    if [[ "$3" = "-f" ]]; then
      db_path="$4"
      mkdir -p $db_path
    fi

    if [ -f "$db_path/ProtecaoDB.txt" ] ; then
      rm -f "$db_path/ProtecaoDB.txt"
    fi

    > $db_path/ProtecaoDB.txt
    ls -lat $2 > $db_path/ProtecaoDB.txt
    printf "Base de dados de proteção do diretório $2 criada na pasta $db_path Com Sucesso!\n"
    chmod 444 $db_path/ProtecaoDB.txt
    ;;
  "-v")
    db_path="$HOME/.protecao"
    if [[ "$3" = "-f" ]]; then
      db_path="$4"
    fi

    if [ ! -f "$db_path/ProtecaoDB.txt" ] ; then
      printf "Não foi encontrado ProtecaoDB.txt neste diretorio em especifico.\n"
      exit 1
    fi

    ls -lat $2 > $db_path/VerificacaoDB.txt

    if diff -q $db_path/ProtecaoDB.txt $db_path/VerificacaoDB.txt >/dev/null ; then
      printf "Não houve modificação dos ficheiros\n"
    else
      diff $db_path/ProtecaoDB.txt $db_path/VerificacaoDB.txt | awk '/rw-rw/ {print $0}' | sort -k 10 > $db_path/Diff.txt

      while read -r -a line
      do
        printf "${line[9]} foi MODIFICADO\n"
        printf "Informacao Inicial: Utilizador: ${line[3]} | Grupo: ${line[4]} | Tamanho: ${line[5]} | Permissoes: ${line[1]} | Tempo Modificacao: ${line[6]} ${line[7]} ${line[8]} |\n"
        read -r -a line
        printf "Informacao Modificada: Utilizador: ${line[3]} | Grupo: ${line[4]} | Tamanho: ${line[5]} | Permissoes: ${line[1]} | Tempo Modificacao: ${line[6]} ${line[7]} ${line[8]} |\n"
      done < $db_path/Diff.txt
    fi
    ;;
  *)
    printf "Invalid switch $1\nUso: ./vigia_pirata.sh [{-p <diretoria[<diretoria>] | -c}] [-f <ficheiro>]\n -p : Protege e guarda informação acerca de uma ou mais diretorias\n -v : Verifica alterações em ficheiros desde que foram protegidos\n -f : Indicação do nome do ficheiro onde a base de dados será guardada\n (Por defeito será $HOME/.protecao)\n"
    ;;
esac