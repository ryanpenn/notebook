# git submodules of the themes
SUBMODULE_URL="https://github.com/spf13/hyde.git"
SUBMODULE_PATH="themes/hyde"

if [ "$1" == "add" ]; then
    git submodule add $SUBMODULE_URL $SUBMODULE_PATH
    git submodule update --init --recursive
    echo "Added submodule $SUBMODULE_PATH"
fi

if [ "$1" == "update" ]; then
    git submodule update --recursive
    echo "Update submodule $SUBMODULE_PATH"
fi

if [ "$1" == "remove" ]; then
    echo "Removing submodule $SUBMODULE_PATH"

    git rm --cached $SUBMODULE_PATH
    rm -rf $SUBMODULE_PATH
    git config -f .gitmodules --remove-section submodule.$SUBMODULE_PATH
    git config -f .git/config --remove-section submodule.$SUBMODULE_PATH

    echo "Committing changes"
    git add .gitmodules
    git commit -m "Removed submodule"

    echo "Removing submodule cache"
    rm -rf .git/modules/$SUBMODULE_PATH
fi

