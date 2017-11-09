#!/bin/bash

: '
Author Akshey Saluja
'
: '
TODO:
Make sure the each octet is 3 characters
'

dispalyOptions(){
: '
This will display all the options and the user will select the desired function.
'
  echo "Please select what you would like to do:"
  echo $'\nTo Whitelist a URL Enter: 1\nTo Whitelist an IP Address Enter: 2
To Blacklist a URL Enter: 3\nTo Blacklist an IP Address Enter: 4\nTo Exclude a Word Enter: 5\n'

echo -n "Enter Option: "
read option
executeOption $option
}

executeOption(){
: '
This will select the user option.
'
if [ "$1" == "1" ]; then
#Whitelist URL
userInput 1
elif [ "$1" == "2" ]; then
#Whitelist IP
userInput 2
elif [ "$1" == "3" ]; then
#Blacklist URL
userInput 3
elif [ "$1" == "4" ]; then
#Blacklist IP
userInput 4
elif [ "$1" == "5" ]; then
#Whitelist Regex
userInput 5

else
    echo -e '\033[1m\nPlease follow Instructions!!!\033[0m'
    echo -e '\033[1mEnter a number that is provided\n\033[0m'
    dispalyOptions
fi

}

userInput(){
: '
This will give the proper input based on the option they choose.

1== Whitelist URL
2== Whitelist IP Address
3== Blacklist URL
4== Blacklist IP Address
5== Whitelist Word in Regex
'

if [ "$1" == "1" ];
then
  echo -n "Enter URL to whilelist: (Ex. URL(https://www.apple.com) Enter .apple.com) "
  read answer
  checkURLInput $answer 3
elif [ "$1" == "2" ];
then
  echo -n "Enter IP Address to whilelist: (Ex. 172.217.20.78) "
  read answer
  checkIPInput $answer 3
elif [ "$1" == "3" ];
then
  echo -n "Enter URL to blacklist: (Ex. URL(https://www.apple.com) Enter .apple.com) "
  read answer
  checkURLInput $answer 4
elif [ "$1" == "4" ];
then
  echo -n "Enter IP Address to blacklist: (Ex. 172.217.20.78) "
  read answer
  checkIPInput $answer 4
elif [ "$1" == "5" ];
then
  echo -n "Enter a word to exclude : (Ex. PipeNipples) "
  read answer
  addToRegex $answer
fi

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
Your input not invalid
Please try again\033[0m'
  dispalyOptions
  return
fi

#Checking if URL begins with http:// or https:// https?://www. || www.
if [[ ${1,,} =~ ^https?:// ]] || [[ ${1,,} =~ ^https?://www. ]] || [[ ${1,,} =~ ^www. ]];then

  echo -e '\033[1mPlease follow Instructions!!!\033[0m
You do not need to enter http:// || https:// || www.\n\033[0m
Please try again\033[0m'
  dispalyOptions
 return
fi

if [ "$2" == "3" ]; then
     addToWhitelist $1 3

elif [ "$2" == "4" ]; then
    addToBlacklist $1 4
fi

}


checkIPInput(){
: '
This will check if what the user entered is valid
$1 == IP
$2 == Whitelist/Blacklist
3 == Whitelist
4 == Blacklist

'

# Check to see if IP Address is valid
if   [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    if [ "$2"=="4" ]; then
       addToWhitelist $1 3

    elif [ "$2" == "4" ]; then
      addToBlacklist $1 4
    fi

    else
      echo -e '\033[1mPlease follow Instructions!!!
Your input not invalid
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
    echo $1 >> /etc/squid/squid-whitelist.acl

  elif [ "$2" == "4" ]; then
    #IP
    echo $1 >> /etc/squid/ip_whitelist.acl

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
      echo $1 >> /etc/squid/squid-manual-blacklist.acl

    elif [ "$2" == "4" ]; then
      #IP
      echo $1 >> /etc/squid/ip_blacklist.acl
    fi
}

addToRegex(){
echo $1 >> /etc/squid/whitelist-regex.acl
}

reconfigureSquid(){
  echo "Reconfiguring Squid "
  /usr/sbin/squid -k reconfigure
  echo "Done"
}

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
reconfigureSquid
echo -e "Thank you for using Akshey Saluja's Squid Program"
exit
