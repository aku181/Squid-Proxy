#!/bin/bash

: '
Author Akshey Saluja
'

#global Variables
SQUIDWHITELIST='/root/testSquid/squid-whitelist.acl'
IPWHITELIST='/root/testSquid/ip_whitelist.acl'
SQUIDBLACKLIST='/root/testSquid/squid-manual-blacklist.acl'
IPBLACKLIST='/root/testSquid/ip_blacklist.acl'
SQUIDREGEX='/root/testSquid/whitelist-regex.acl'
ACCESSLOG='/var/log/squid/access.log'


dispalyOptions(){

: '
This will display all the options and the user will select the desired function.
'
  echo "Please select what you would like to do:"
  echo -e $'\n\033[1mEnter: 1\033[0m To Whitelist a URL \n\033[1m\033[1mEnter: 2\033[0m To Whitelist an IP Address
\033[1mEnter: 3\033[0m To Blacklist a URL \n\033[1mEnter: 4\033[0m To Blacklist an IP Address \n\033[1mEnter: 5\033[0m To Exclude a Word
\033[1mEnter: 6\033[0m To Find a Keyword or an IP Address in the access.log file\n'

echo -n "Enter Option: "
read option
executeOption $option
}

executeOption(){
: '
This will select the user option.
'
case $1 in
  "1" )
  #Whitelist URL
  userInput 1
    ;;
    "2")
    #Whitelist IP
    userInput 2
    ;;
    "3")
    #Blacklist URL
    userInput 3
    ;;
    "4")
    #Blacklist IP
    userInput 4
    ;;
    "5")
    #Whitelist Regex
    userInput 5
    ;;
    "6")
    #Read accesslog
    userInput 6
    ;;
    *)
    echo -e '\033[1m\nPlease follow Instructions!!!
Enter a number that is provided\n\033[0m'
    dispalyOptions
    ;;
esac
}

userInput(){
: '
This will give the proper input based on the option they choose.

1== Whitelist URL
2== Whitelist IP Address
3== Blacklist URL
4== Blacklist IP Address
5== Whitelist Word in Regex
6== Find Keyword or IP Address in access log
'
case $1 in
  "1" )
  echo -n "Enter URL to whilelist: (Ex. URL(https://www.apple.com) Enter .apple.com) "
  read answer
  checkURLInput $answer 3
    ;;
    "2")
    echo -n "Enter IP Address to whilelist: (Ex. 172.217.20.78) "
    read answer
    checkIPInput $answer 3
    ;;
    "3")
    echo -n "Enter URL to blacklist: (Ex. URL(https://www.apple.com) Enter .apple.com) "
    read answer
    checkURLInput $answer 4
    ;;
    "4")
    echo -n "Enter IP Address to blacklist: (Ex. 172.217.20.78) "
    read answer
    checkIPInput $answer 4
    ;;
    "5")
    echo -n "Enter a word to exclude : (Ex. PipeNipples) "
    read answer
    addToRegex $answer
    ;;
    "6")
    echo -n "Enter Keyword or IP Address to find in the access Logs: "
    read answer
    readAccessLog $answer
    ;;
esac
}

checkURLInput(){
: '
This will check if what the user entered is valid.
$1 == URL
$2 == Whitelist/Blacklist
3 == Whitelist
4 == Blacklist

'
#Check to see if input is not empty
if [[ -z "$2" ]]; then
  echo -e '\033[1mPlease follow Instructions!!!
Your input is invalid
Please try again\033[0m'
  dispalyOptions
  return
fi

#Checking if URL begins with http:// or https:// https?://www. || www.
if [[ ${1,,} =~ ^https?:// ]] || [[ ${1,,} =~ ^https?://www. ]] || [[ ${1,,} =~ ^www. ]];then

  echo -e '\033[1mPlease follow Instructions!!!
You do not need to enter http:// || https:// || www.\n\033[0m
Please try again\033[0m'
  dispalyOptions
 return
fi

if [ "$2" == "3" ]; then
     addToWhitelist $1 3

elif [ "$2" == "4" ]; then
    addToBlacklist $1 3
fi

}

checkIPInput(){
: '
This will check if what the user entered is valid
$1 == IP
$2 == Whitelist/Blacklist
3 == Whitelist
4 == Blacklist
5 == grep IP Address

'
# Check to see if IP Address is valid
if   [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    if [ "$2" == "3" ]; then
       addToWhitelist $1 4

    elif [ "$2" == "4" ]; then
       addToBlacklist $1 4
    fi

    else
      echo -e '\033[1mPlease follow Instructions!!!
Your input is invalid
Please try again\033[0m'
        dispalyOptions
        return
fi
}

addToWhitelist(){
: '
This will add the userInput to the appropriate file
$1 == URL /IP
$2 == option
3 == URL
4 == IP Address
'
  if [ "$2" == "3" ]; then
    # URL
    echo $1 >> $SQUIDWHITELIST

  elif [ "$2" == "4" ]; then
    #IP
    echo $1 >> $IPWHITELIST

  fi

}

addToBlacklist(){
: '
This will add the userInput to the appropriate file
$1 == URL /IP
$2 == option
3 == URL
4 == IP Address
'
    if [ "$2" == "3" ]; then
      # URL
      echo $1 >> $SQUIDBLACKLIST

    elif [ "$2" == "4" ]; then
      #IP
      echo $1 >> $IPBLACKLIST
    fi
}

addToRegex(){
  : '
  This will add the userInput to the appropriate file
  $1 == Word
  '
  #Check to see if input is not empty
  if [[ -z "$1" ]]; then
    echo -e '\033[1mPlease follow Instructions!!!
Your input is invalid
Please try again\033[0m'
    dispalyOptions
    return
  fi

echo $1 >> $SQUIDREGEX
}

readAccessLog(){
: '
This will allow the user to tail -f  $1 /var/log/squid/access.log
$1 == Keyword or IP
'
tail -f $ACCESSLOG | grep $1 & # run in background
read -sn 1 #wait for user input
kill %1 #kill the first background progress, i.e. tail

}

reconfigureSquid(){
  echo "Reconfiguring Squid "
  /usr/sbin/squid -k reconfigure
  echo "Done"
}
main(){
# Check to make sure user is running as root
if [[ "$(whoami)" != "root" ]]; then
  echo -e '\033[1mPlease Run the Program with sudo
i.e sudo ./whitelist_url.sh\033[0m'
exit
fi

X=1
while [ $X = 1 ]
do
dispalyOptions
echo -n "Do you want to choose another option? (yes/no) "
read answer
if echo $answer | grep -iq "^n"; then
        X=2
fi

done
#reconfigureSquid
echo -e "Thank you for using Akshey Saluja's Squid Program"
exit
}

main
