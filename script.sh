# log $1 in underline green then $@ in yellow
log() { echo -e "\033[1;4;32m${1}\033[0m \033[1;33m${@:2}\033[0m"; }

# echo $1 in underline red then $@ in cyan (to the stderr)
err() { echo -e "\033[1;4;31m${1}\033[0m \033[1;36m${@:2}\033[0m" >&2; }

# abort if sudo access is already enabled
[[ -n $(sudo -n uptime 2>/dev/null) ]] && { err abort root access unauthorized; exit; }

DOCUMENTS=$(xdg-user-dir DOCUMENTS)

# ask sudo access
log warn sudo access required...
sudo echo >/dev/null
# one more check if the user abort the password question
[[ -z `sudo -n uptime 2>/dev/null` ]] && { err abort sudo required; exit; }

#
# apt update, upgrade, install
#

log apt update
sudo apt update

log apt upgrade
sudo apt upgrade --yes

while read package
do
    log apt install $package
    sudo apt install --yes $package
done << EOF
ack
curl
docker
git
jq
obs-studio
tree
youtube-dl
EOF

# apt install opera
log apt install opera
# add source if not already added (script previously executed)
if [[ -n $(grep opera-stable /etc/apt/sources.list.d/*) ]]
then
    sudo add-apt-repository 'deb https://deb.opera.com/opera-stable/ stable non-free'
fi
# list with `cat /etc/apt/sources.list`
# manual edit with `sudo nano /etc/apt/sources.list`
# remove with `sudo add-apt-repository --remove 'deb https://deb.opera.com/opera-stable/ stable non-free'`

wget http://deb.opera.com/archive.key \
    --output-document=- \
    --quiet \
    | sudo apt-key add -
# list with `apt-key list`
# remove manually with:
#
# 1) apt-key list
# pub   rsa4096 2019-09-12 [SC] [expire : 2021-09-11]
#    68E9 B2B0 3661 EE3C 44F7  0750 4B8E C3BA ABDC 4346
# uid          [unknown] Opera Software Archive Automatic Signing Key 2019 <packager@opera.com>
#
# 2) then `sudo apt-key del 'ABDC 4346'`
sudo apt update
sudo apt install --yes opera-stable

# remove duplicate source warning : https://askubuntu.com/a/184446
if [[ -n $(grep opera-stable /etc/apt/sources.list.d/*) ]]
then
    sudo add-apt-repository --remove 'deb https://deb.opera.com/opera-stable/ stable non-free'
fi

# apt install code
log apt install code
if [[ -z $(grep vscode /etc/apt/sources.list.d/*) ]]
then
    sudo add-apt-repository 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main'
fi

wget https://packages.microsoft.com/keys/microsoft.asc \
    --output-document=- \
    --quiet \
    | sudo apt-key add -

sudo apt update
sudo apt install code

# remove duplicate source warning
if [[ -n $(grep vscode /etc/apt/sources.list.d/*) ]]
then
    sudo add-apt-repository --remove 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main'
fi


#
# other installs
#

# soulseek
log install soulseek
cd $DOCUMENTS
curl raw.github.com/jeromedecoster/soulseek/master/script.sh \
    --location \
    --silent \
    | bash