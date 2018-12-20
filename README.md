Les instructions suivantes détaillent comment mettre en place le serveur Docker-company sur un ordinateur doté d'un système d'exploitation Linux.

Pré-requis :

Être connecté sur le réseau comany
Avoir un ordinateur sous Linux (centos/archlinux/fedora/ubuntu/linux mint/debian)
Avoir un compte google « company.com »

1/ Télécharger le script company-docker.zip

2/ Set les droits d’exécutions du script
	Une fois sur votre ordinateur, il vous faudra set les droits d’exécutions avec la commande : 	chmod +x company-docker.sh

3/ Aller à l'adresse https://coreos.company.com:5001 via votre navigateur
Vous devriez tomber sur cette page
Cliquez sur « Login with Google account » puis sur « Sign in with Google »
Renseignez votre compte Google company.com ainsi que votre mot de passe.
Acceptez les autorisations requises pour l'authentification.
Si tout c'est déroulé correctement vous devriez voir apparaître votre token.

4/ Lancez le script company-docker.sh
Il est nécessaire de lancer le script avec un compte utilisateur qui possède les droits sudo.
	La configuration de l’environnement est temporaire et n'est valide que dans le terminal où 	est lancé le script.

Le script se prototype de la manière suivante :
 « $>company-docker login token » ou « $>company-docker -f /path_to_param/file.txt »
Un exemple du fichier file.txt est disponible dans l'archive afin de voir la syntaxe de celui-ci.
Si tout ce déroule comme prévu vous devriez voir « Login Succeeded » à la fin de l’exécution.

	A SAVOIR

	Après la première exécution, et si votre système le permet, company-docker sera installé dans /usr/local/bin par défaut.

	Si /usr/local/bin n'est pas dans votre env path, il vous sera demandé si vous souhaitez installer company-docker dans /usr/bin.

	Vous aurez donc la possibilité d'utiliser directement la commande company-docker pour 	configurer votre environnement. (ex : « $>company-docker -f param.txt »)

5/ Utilisation
	Quick Start ici :https://docs.docker.com/engine/userguide/dockerizing/

	Exemple d'utilisation, lancement d'un docker ubuntu et vérification que celui-ci s’exécute 	sur le serveur.



En Cas d'Erreur

- « Error response from daemon: no successful auth challenge for http://ip_server_docker_registry:5000/v2/ - errors: [token auth attempt for registry http://ip_server_docker_registry:5000/v2/: https://ip_server_docker_registry:5001/auth?account=first.last%40company.com&service=Docker+registry request failed with status: 401 Unauthorized] » → Token ou login invalide.

- « >> Don't start this script with sudo instance << » → ne pas executer le script « $>sudo ./company-docker -f param » mais « $>./company-docker -f param ».

- « Please install Curl on your system. » → le script a besoin de curl pour fonctionner correctement, veuillez installer curl sur votre machine.

- « The minimum version required of kernel is 3.10. Please update your computer"
     The current version of your kernel is: x.xx.xx » → docker à besoin d'un kernel v 3.10 minimum pour s’exécuter correctement.

- « Error check the stderr. » → erreur durant l’installation de docker.

- « You're Docker version API is different than the Docker version API of the Server
      Please uninstall and install the appropriate version of Docker » → vous avez déjà installé docker et votre version est supérieur à celle utilisé sur le serveur. Afin de pouvoir utiliser le serveur, désinstaller votre version et installer celle correspondante.

- « Error, your system is not suported by the script for an installation of docker, please install it manually » → Votre distribution de linux n'est pas supporter par le script pour une installation de docker, veuillez l'installer manuellement.

- « Cannot connect to the Docker daemon. Is the docker daemon running on this host? » → Votre session n'est pas configuré, veuillez utiliser le script afin de configurer votre environnement. 
