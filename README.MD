# CONFIGURAÇÃO JENKINS

## Executando pela primeira vez
O arquivo base para executar o `Jenkins`, utilizando docker compose, arquivo `docker-compose.yml`, terá uma estrutura parecida com o seguinte:
```yml
version: '3'

networks:
  jenkins-network:
    name: jenkins-network

services:
  jenkins:
    container_name: jenkins
    image: jenkins/jenkins:lts-jdk21
    ports:
      - 8080:8080
    networks:
      - jenkins-network
    volumes:
      - jenkins_home:/var/jenkins_home

volumes:
  jenkins_home:
```

Para executar, utilize o seguinte comando:
```shell
docker compose up
```
Se não desejar que os logs fiquem sendo exibidos no shell, basta adicionar `-d` como no exemplo abaixo:
```shell
docker compose up -d
```
Isso irá baixar a imagem do Jenkins na versão especificada no arquivo; irá criar um volume chamado `jenkins_jenkins_home`; e irá executar o `Jenkins` na porta especificada no arquivo `docker-dompose.yml`, por padrão, o `Jenkins` roda na porta 8080.

Acesse pelo navegador [http://localhost:8080](http://localhost:8080), o `Jenkins` irá solicitar uma senha inicial conforme imagem a seguir:
![Tela inicial Jenkins](https://github.com/marcelocezario/imagens-publicas/blob/main/projeto-jenkins/Tela%20inicial%20Jenkins.png?raw=true)

Para conseguir essa senha, basta executar o seguinte comando:
```shell
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
Copie o valor gerado no terminal, e cole no campo de senha e clique em "Continuar".

Na tela seguinte, será solicitado para instalar extensões sugeridas ou selecionar extensões, sugiro escolher a opção "Instalar as extensões sugeridas":
![Opções de extensões](https://github.com/marcelocezario/imagens-publicas/blob/main/projeto-jenkins/Op%C3%A7%C3%B5es%20de%20extens%C3%B5es.png?raw=true)

Após isso, será instalado as extensões selecionadas ou recomendas:
![Instalando plugins](https://github.com/marcelocezario/imagens-publicas/blob/main/projeto-jenkins/Instalando%20plugins.png?raw=true)

Instalado os plug-ins, o `Jenkins` irá solicitar que crie o primeiro usuário Administrador, preencha os campos e clique em "Salvar e continuar":
![Criando primeiro usuário Administrador](https://github.com/marcelocezario/imagens-publicas/blob/main/projeto-jenkins/Criando%20primeiro%20usu%C3%A1rio%20Administrador.png?raw=true)

Na tela a seguir, basta apenas confirmar a URL do `Jenkins` e clicar em "Gravar e Concluir":
![Confirmando URL Jenkins](https://github.com/marcelocezario/imagens-publicas/blob/main/projeto-jenkins/Confirmando%20URL%20Jenkins.png?raw=true)

Pronto, o `Jenkins` está configurado, basta clicar em "Começar a usar o Jenkins", após isso, você será direcionado para a tela inicial do `Jenkins`, conforme imagem a seguir:
![Home page Jenkins](https://github.com/marcelocezario/imagens-publicas/blob/main/projeto-jenkins/Home%20page%20Jenkins.png?raw=true)

## Hello World Jenkins!
Vamos criar um primeiro projeto Hello World. Vá em:
1. "Nova tarefa";
2. Digite um nome, aqui vamos chamar de "HelloWorld";
3. Selecione a opção "Contruir um projeto de softwre de estilo livre" (free-style);
4. Clique em "Tudo certo";
5. Vamos procurar pela opção "Build" ou "Passos de construção";
6. Selecione a opção "Executar shell" 



## Plugin JCasC - Jenkins Configuration as Code
O JCasC pode ser usado para utilizar as configurações do `Jenkins` como código, podendo assim versionar alterações e replicar para outros ambientes como local e server.

### Instalando JCasC
* No painel do Jenkins, clique em Gerenciar Jenkins > Gerenciar Plugins.
* Na aba Disponíveis, procure por Configuration as Code.
* Marque o plugin e clique em Instalar sem reiniciar.

⚠️ Nota: Caso o plugin não apareça na aba Disponíveis, ele já pode estar instalado. Verifique em Instalados.
![Instalando Configuration as Code](https://github.com/marcelocezario/imagens-publicas/blob/main/projeto-jenkins/Instalando%20Configuration%20as%20Code.png?raw=true)

### Exportar configuração atual
Após instalar o plugin, vá para: Gerenciar Jenkins > Configuration as Code.

Se clicar em "View Configuration", o Jenkins mostrará a configuração YAML atual, que contém:
* Plugins instalados.
* Configurações de segurança.
* Credenciais.

Ao clicar no botão "Download Configuration", o `Jenkins` irá baixar o arquivo YAML que poderá ser versionado, basta adicionar o arquivo baixado no diretório versionado.

### Adicionando configuração JCasC no docker compose
Adicione o mapeamento do volume e a variável de ambiente do JCasC:
```yml
    volumes:
      - ./jenkins-config:/var/jenkins_home/config   # Diretório com o arquivo jenkins.yaml
    environment:
      - CASC_JENKINS_CONFIG=/var/jenkins_home/config/jenkins.yaml  # Variável de configuração
```

Então, nesse ponto, nosso `docker-compose.yml` estará da seguinte forma:
```yml
version: '3'

networks:
  jenkins-network:
    name: jenkins-network

services:
  jenkins:
    container_name: jenkins
    image: jenkins/jenkins:lts-jdk21
    ports:
      - 8080:8080
    networks:
      - jenkins-network
    volumes:
      - jenkins_home:/var/jenkins_home
      - ./jenkins-config:/var/jenkins_home/config
    environment:
      - CASC_JENKINS_CONFIG=/var/jenkins_home/config/jenkins.yaml

volumes:
  jenkins_home:
```

Pode reiniciar o container:
```shell
docker compose down
docker compose up -d
```

Feito essas configurações, ao executar `docker compose up`, se o plugin JCasC estiver configurado corretamente, e o arquivo de configurações `jenkins.yaml` estiver na pasta `jenkins-config` o jenkins já vai carregar automaticamente as configurações pré configurados do arquivo e credenciais.

## Adicionando JDK
**ATENÇÃO: não consegui testar os passos seguintes, pois já estou utilizando uma versão do `Jenkins` do docker que já vem pré-configurado com a JDK 21, portanto o passo a seguir sempre acabava resultando em erro, vou manter as anotações, pois no futuro pode ser importante essa análise novamente.**

Por questões de compatibilidade entre diferentes ambientes, pode ser interessante a instalação da JDK ser feita de forma automática pelo Jenkins, mas posso estar enganado e talvez essa não ser a melhor abordagem, porém é o que faremos aqui:

Vá para: Gerenciar Jenkins > Tools
1. Procure por JDK instalações;
2. Clique em "Adicionar JDK";
3. Atribua um nome, usarei como exemplo: "jdk_21";
4. Marque a opção "Instalar automaticamente" e clique em "Adicionar instalador";
5. Vá em "Executar comando" e adicione o seguinte comando:
```shell
sudo apt-get update && sudo apt-get install -y openjdk-21-jdk
```
6. Em "Home da ferramenta", adicione: 
```shell
/usr/lib/jvm/java-21-openjdk
```
7. Clique em "Save";
![Configuração JDK no Jenkins](https://github.com/marcelocezario/imagens-publicas/blob/main/projeto-jenkins/Configura%C3%A7%C3%A3o%20JDK%20no%20Jenkins.png?raw=true)

## Adicionando Maven
A adição do maven é muito semelhante a adição da jdk, até mais simples:
1. Defina um nome;
2. Marque a opção "instalar automaticamente";
3. Escolha uma versão, para esse exemplo estamos usando a versão "3.9.9";
4. Clique em "Save";
![Configuração Maven no Jenkins](https://github.com/marcelocezario/imagens-publicas/blob/main/projeto-jenkins/Configura%C3%A7%C3%A3o%20Maven%20no%20Jenkins.png?raw=true)

Feito essa configuração, para usar o `Maven` numa pipeline, indique o uso da ferramenta em tools na pipeline:
```groovy
pipeline {
    agent any
    tools {
        maven '3.9.9'
    }
    stages {
        stage ('Executando teste Maven') {
            steps {
                echo 'Fazendo um teste do maven'
                sh 'mvn test'
            }
        }
    }
}
```

