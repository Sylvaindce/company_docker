#!/bin/bash -l

##Decombe Sylvain##
###################

## variables

username=$1
password=$2

src_docker="/etc/apt/sources.list.d/docker.list"

host="tcp://coreos.company.com:2375"

tmp_scr="./tmp_script.sh"

error=0

## colors
ESC="\033["
C_RED=$ESC"0;31m"
C_GREEN=$ESC"0;32m"
C_YELLOW=$ESC"0;33m"
C_BLUE=$ESC"0;34m"
C_BWHITE=$ESC"1;37m"
C_RST=$ESC"0m"

function usage
{
    echo
    echo -ne $C_BWHITE
    echo -e "Becarful:$C_BLUE You have to connect at this address before $C_BWHITE https://coreos.company.com:5001"
    echo 
    echo -e $C_RED"Usage: $0 $C_YELLOW<username> <password>$C_RED OR $0 $C_YELLOW-f param.txt"
    echo
    echo -e $C_BLUE"Username = $C_YELLOW<Google Address>"
    echo -e $C_BLUE"Password = $C_YELLOW<Token given by Google>"
    echo -e $C_BLUE
    echo -ne "#####EXAMPLE OF param.txt####\n\n$>cat -e param.txt\n$C_YELLOW"
    echo -e "firstname.lastname@company.com$\njcsidh65s65csgeuzf5564eaez$"
    echo -ne $C_RST
    echo
}

function get_param
{
    version=(`cat $password | tr '\n' ' '`)
    username=${version[0]}
    password=${version[1]}
}

if test $UID -eq 0;  then
    echo
    echo -ne $C_RED
    echo -ne ">> Don't start this script with sudo instance <<"
    echo -ne $C_RST
    echo
    usage
    exit 1
fi

if test -z "$username" || test -z "$password"; then
    usage
    exit 1
fi

if [ "$username" == "-f" ];then
    if [ -f "$password" ];then
    	get_param  	
    else
	echo
    	echo -e $C_RED">> ERROR, Please verify if the file exist and not empty too. <<"
	echo -ne $C_RST
	echo
	usage
	exit 1
    fi
fi

function install
{
    env=(`env | grep "PATH="`)
    
    for i in `seq 0 10`;
    do
	if [ "${env[$i]:0:5}" == "PATH=" ]; then
	    ret=$i
	fi
    done
    tmpenv=(`echo ${env[$ret]:5} | tr ':' ' '`)
    localexist=(`env | grep /usr/local/bin`)
    for i in `seq 0 10`;
    do
	if [ "${tmpenv[$i]}" == "/usr/local/bin" ]; then
	    if [ ! -s /usr/local/bin/company_docker ]; then
		echo -e $C_BLUE"Install company_docker in /usr/local/bin"
		echo -ne $C_RST
		sudo cp company_docker.sh /usr/local/bin
		sudo mv /usr/local/bin/company_docker.sh /usr/local/bin/company_docker
		sudo chmod 777 /usr/local/bin/company_docker
	    fi
	fi
	if [ "${localexist:0:5}" != "PATH=" ]; then
	    if [ "${tmpenv[$i]}" == "/usr/bin" ]; then
		echo -ne $C_GREEN"Do yo want install company_docker inside /usr/bin ? [Y/n] "$C_RST
		read answer
		if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]; then
		    echo -e $C_BLUE"Install company_docker in /usr/bin"
	    	    echo -ne $C_RST
	    	    sudo cp company_docker.sh /usr/bin
	    	    sudo mv /usr/bin/company_docker.sh /usr/bin/company_docker
	    	    sudo chmod 777 /usr/bin/company_docker
		elif [ "${answer:0:1}" == "n" ] || [ "${answer:0:1}" == "N" ]; then
		    echo
		    echo -e $C_RED"No?, Well you have to use the company_docker script when you want to use the company docker server."$C_RST
		    echo
		else
		    install
		fi
	    fi
	fi
    done    
}

function resume
{
    echo
    echo -ne $C_BWHITE
    echo "Your informations:"
    echo
    echo -e $C_BLUE"Username = $C_YELLOW$username"
    echo -e $C_BLUE"Password = $C_YELLOW$password"
    echo -e $C_BLUE"Email = $C_YELLOW$username"
    echo -ne $C_RST
    echo
}

function check_dependency
{
    echo
    echo -ne $C_BWHITE
    echo "CHECKING DEPENDENCY"
    echo -ne $C_RST
    echo
    curlapp=(`curl -h | tr '-' ' '`)
    if [ "${curlapp[1]}" == "curl" ]
    then
	echo -ne $C_GREEN
	echo "Curl is already installed."
	echo -ne $RST
    else
	echo -ne $C_RED
	echo "Please install Curl on your system."
	echo -ne $C_RST
	exit
    fi
}

function check_kernel
{
    kernel=$(uname -r)
    version=(`uname -r | tr '.' ' '`)
    
    echo
    echo -ne $C_BWHITE
    echo "CHECKING KERNEL VERSION"
    echo -ne $C_RST
    echo
    
    if (("${version[0]}" < "3")); then
	echo
	echo -ne $C_RED
	echo "The minimum version required of kernel is 3.10. Please update your computer"
	echo
	echo -ne $C_BLUE
	echo "The current version of your kernel is: $kernel"
	echo  -ne $C_RST
	echo
	exit 1
    elif (("${version[0]}" == "3")) && (("${version[1]}" < "10")); then
	echo
	echo -ne $C_RED
	echo "The minimum version required of kernel is 3.10. Please update your computer"
	echo
	echo -ne $C_BLUE
	echo "The current version of your kernel is: $kernel"
	echo  -ne $C_RST
	echo
	exit 1
    fi
    echo -e $C_GREEN"KERNEL OK!"
    echo -ne $C_RST
}

function check_docker
{
    echo
    echo -ne $C_BWHITE
    echo "CHECKING DOCKER WORKSPACE"
    echo -ne $C_RST
    echo
    
    docker_cli=(`docker --version | tr ' ' ' '`)
    docker_serv=(`curl -L http://coreos_docker_server_ip:port/info | tr ',' ' '`)
    
    error=$((error+1))
    if (("$error" >= "3")); then
	echo "Error check the stderr."
	exit 1
    fi
    for i in `seq 0 50`;
    do
	tmp=(`echo ${docker_serv[$i]} | grep "ServerVersion"`)
	if [ "${tmp:0:15}" == "\"ServerVersion\"" ]; then
	    ret=$i
	fi
    done
    
    if [ "${docker_cli[0]}" == "Docker" ]; then
	srv_ver=${docker_serv["$ret"]:17:3}
	clt_ver=${docker_cli[2]:0:3}
	echo
	echo -e $C_BLUE"SERVER DOCKER VERSION: $C_YELLOW$srv_ver"
	echo -e $C_BLUE"CLIENT DOCKER VERSION: $C_YELLOW$clt_ver"
	if [ $srv_ver == $clt_ver  ]; then
	    echo -e $C_GREEN
	    echo "ALL IS CORRECT."
	    echo -ne $C_RST
	    conf_docker
	else
	    echo -ne $C_RED
	    echo "You're Docker version API is different than the Docker version API of the Server"
	    echo "Please uninstall and install the appropriate version of Docker"
	    echo "Your version is: $client"
	    echo "$server"
	    echo -ne $C_RST
	    exit 1
	fi
    else
	select_system
    fi
}

function select_system
{
    id=0
    release=0
    cd=0
    #echo "${system[$id]:11}"
    if [ -s /etc/centos-release ]; then
    	install_centos
    elif [ -f /etc/arch-release ]; then
    	install_arch
    elif [ -s /etc/fedora-release ]; then
    	install_fedora
    system=(`cat /etc/lsb-release | tr '\n' ' '`)
    for i in `seq 0 10`;
    do
	tmp=(`echo ${system[$i]}`)
	if [ "${tmp:0:11}" == "DISTRIB_ID=" ]; then
	    id=$i
	elif [ "${tmp:0:17}" == "DISTRIB_CODENAME=" ]; then
	    cd=$i
	elif [ "${tmp:0:16}" == "DISTRIB_RELEASE=" ]; then
	    release=$i
	fi
    done
    elif [ "${system[$id]:11}" == "Ubuntu" ]; then
	prepare_apt_debian
	ubuntu_source ${system[$cd]}
	install_debian
    elif [ "${system[$id]:11}" == "LinuxMint" ]; then
	prepare_apt_debian
	mint_source ${system[$release]}
	install_debian
    elif [ -s /etc/debian_version ]; then
    	prepare_apt_debian
	debian_source
	install_debian
    else
	echo -ne $C_RED
	echo "Error, your system is not suported by the script for an installation of docker, please install it manually"
	echo -ne $C_RST
	exit 1
    fi
    check_docker
}

##BEGIN INSTALL ARCHLINUX

function install_arch
{
    echo
    echo -ne $C_BWHITE
    echo "INSTALLING DOCKER ON ARCHLINUX"
    echo -ne $C_RST
    echo
    sudo pacman -S docker
    sudo systemctl enable docker   
    sudo systemctl start docker
}

##END ARCHLINUX INSTALL

##BEGIN FEDORA INSTALL

function install_fedora
{
    echo
    echo -ne $C_BWHITE
    echo "INSTALLING DOCKER ON FEDORA"
    echo -ne $C_RST
    echo
    
    sudo yum update
    sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/fedora/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
    sudo yum install docker-engine
    sudo service docker start
}

##END FEDORA INSTALL

##BEGIN CENTOS INSTALL

function install_centos
{
    echo
    echo -ne $C_BWHITE
    echo "INSTALLING DOCKER ON CENTOS"
    echo -ne $C_RST
    echo
    
    sudo yum update
    sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
    sudo yum install docker-engine
    sudo service docker start
}

##END CENTOS INSTALL

##BEGIN DEBIAN INSTALL

function prepare_apt_debian
{
    echo
    echo -ne $C_BWHITE
    echo "INITIALIZING APT SOURCES"
    echo -ne $C_RST
    echo
    sudo apt-get purge lxc-docker*
    sudo apt-get purge docker.io*
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    if [ ! -f "$src_docker" ]
    then
	echo -ne $C_RED
	echo "File $src_docker does not exist."
	echo -e $C_BLUE"Creation of $src_docker file."
	echo -ne $C_RST
	sudo touch $src_docker
    fi
}

function debian_source
{
    read -d / VERSION < /etc/debian_version
    echo
    echo -ne $C_BLUE
    echo -n "You're version of Debian is: "
    echo -ne $C_YELLOW
    echo ${VERSION[0]}
    echo
    echo -e $C_BLUE"Adding the appropriate source."
    echo -ne $C_RST
    sudo chmod 777 $src_docker
    if [ "${VERSION[0]}" == "jessie" ] || (( "${VERSION[0]:0:1}" == "8" )); then
	sudo echo "deb https://apt.dockerproject.org/repo debian-jessie main" > $src_docker
    elif [ "${VERSION[0]}" == "wheezy" ] || (( "${VERSION[0]:0:1}" == "7" )); then
	sudo echo "deb https://apt.dockerproject.org/repo debian-wheezy main" > $src_docker
    elif [ "${VERSION[0]}" == "stretch" ] || (( "${VERSION[0]:0:1}" == "9" )); then
	sudo echo "deb https://apt.dockerproject.org/repo debian-stretch main" > $src_docker
    else
       	echo -ne $C_RED
	echo "Error, your system is not suported by the script for an installation of docker, please install it manually"
	echo -ne $C_RST
	exit 1
    fi
}

function ubuntu_source
{
    ver=$1
    echo
    echo -ne $C_BLUE
    echo -n "You're version of Ubuntu is: "
    echo -ne $C_YELLOW
    echo ${ver:17}
    echo
    echo -e $C_BLUE"Adding the appropriate source."
    echo -ne $C_RST
    sudo chmod 777 $src_docker
    if [ "${ver:17}" == "precise" ]; then
    	sudo echo "deb https://apt.dockerproject.org/repo ubuntu-precise main" > $src_docker
    elif [ "${ver:17}" == "trusty" ]; then
    	sudo echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > $src_docker
    elif [ "${ver:17}" == "vivid" ]; then
    	sudo echo "deb https://apt.dockerproject.org/repo ubuntu-vivid main" > $src_docker
    elif [ "${ver:17}" == "willy" ]; then
    	sudo echo "deb https://apt.dockerproject.org/repo ubuntu-willy main" > $src_docker
    else
	echo -ne $C_RED
	echo "Error, your system is not suported by the script for an installation of docker, please install it manually"
	echo -ne $C_RST
	exit 1
    fi
}

function mint_source
{
    ver=$1
    echo
    echo -ne $C_BLUE
    echo -n "You're version of Mint is: "
    echo -ne $C_YELLOW
    echo ${ver:16}
    echo
    echo -e $C_BLUE"Adding the appropriate source."
    echo -ne $C_RST
    sudo chmod 777 $src_docker
    if (( "${ver:16:2}" >= "17" )); then
    	sudo echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > $src_docker
    else
	echo -ne $C_RED
	echo "Error, your system is not suported by the script for an installation of docker, please install it manually"
	echo -ne $C_RST
	exit 1
    fi
}

function install_debian
{
    echo
    echo -ne $C_BWHITE
    echo "INSTALLING DOCKER ON DEBIAN BASED SYSTEM"
    echo -ne $C_RST
    echo
    sudo apt-get update
    sudo apt-cache policy docker-engine
    sudo apt-get install apt-transport-https
    sudo apt-get update
    sudo apt-get -y -f install docker-engine
    sudo service docker start
}

##END DEBIAN INSTALL

function conf_docker
{
    echo
    echo -ne $C_BWHITE
    echo "CONFIGURING DOCKER"
    echo -ne $C_RST
    echo
    install
    echo -ne $C_BLUE
    echo "Set DOCKER_HOST environment variable"
    echo "#!/bin/bash" > $tmp_scr
    echo "echo export DOCKER_HOST=$host" >> $tmp_scr
    chmod +x $tmp_scr
    eval $($tmp_scr)
    echo "Logging into the registry ..."
    echo -ne $C_RST
    docker login --username="$username" --password="$password" --email="$username" https://ip_addr_docker_registry:5000
    rm -f $tmp_scr
    export DOCKER_HOST=$host
    exec $SHELL -i
    exit 1
}

resume
check_dependency
check_kernel
check_docker

##Decombe Sylvain##
###################
