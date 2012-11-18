if [[ -d ~/.git ]]; then
    echo "Oh my. It looks like you already have a Git repository in your home directory. You'll need to fix this before you install the dotfiles."
    exit
fi

if [[ -d ~/dotfiles.old ]]; then
    echo "Well, I was going to put all your old files into dotfiles.old, but it appears you already have a directory named that. Move it and try again... Please?"
    exit
fi

hash git 2> /dev/null || {
    echo "Oh dear. I require Git, but it's not installed."
}

echo "Initializing a blank repo..."
git init

echo "Adding dotfiles remote origin...."
git remote add origin https://github.com/jdavis/dotfiles.git

echo "Fetching code..."
git fetch

# Create a place to store all the existing files so we dont' have a clash
mkdir dotfiles.old
git ls-tree origin/master | xargs mv -t dotfiles.old/

git merge origin master

echo "Let submodule this shit..."
git submodule init
git submodule update

builtin cd ~/.vim
git submodule init
git submodule update

echo "To install Vundle Bundles, run the command below:"
echo "\tvim +BundleInstall +qall"

echo "Dotfiles are now installed. Proceed to conquer the universe."
source ~/.zshrc
