SUBMODULE_PATH="themes/diary"

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