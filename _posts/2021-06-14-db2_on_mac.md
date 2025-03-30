---
header:
  image: /assets/uploads/db2-blog/db2-blog.png
title: Connecting to DB2 on MacOS with Python (Intel and Apple Silicon)
date: 2021-06-14T03:00:00.000Z
tags:
  - Programming
  - Guide
  - Tutorial
  - Python
author: content/authors/Alex-Oladele.md
---
If you’ve tried to connect to a DB2 database using the ibm-db package, you might have run into this issue at some point.

After hours and even days of Googling, I finally compiled a number of Github issues and Stack overflow posts to come to the solution to this problem.

***

## Connecting to IBM DB2 on MacOS (Intel) with Python

Here are the steps I used to solve this problem:

1. Install Python 3.x via Homebrew. Doing so allows give you a more standard location for the Python3.x executable

```shell
# Example: brew install python @3.9
brew install python @3.x

# Add the installed Python brew to your PATH
echo 'export PATH="/usr/local/opt/python@3.x/bin:$PATH"' >> ~/.zshrc # If zsh is your default shell
echo 'export PATH="/usr/local/opt/python@3.x/bin:$PATH"' >> ~/.bashrc # If bash is your default shell

source ~/.zshrc # If zsh is your default shell
source ~/.bashrc # If bash is your default shell
```

1. Make sure you’re using a virtual environment. I primarily use Pycharm IDE, so isolating this issue to a virtual environment made it easier to fix for me.

```shell
# Double check this is the python version you're wanting to use
python3--version

# Move to your project folder
cd project_folder

# Create the virtual environment in your project folder
python3 - m venv venv
```

1. Activate your virtual environment. If you don’t do this, the below script won’t work

```shell
source venv / bin / activate
```

1. Run the following script ([https://gist.github.com/dragid10/afb9b16d72c4f7807938bd28c37f6ad3](https://gist.github.com/dragid10/afb9b16d72c4f7807938bd28c37f6ad3))

```shell
# Only need to execute this when running on mac
set - ex
py_folder = $(ls venv / lib | head - n 1)
cd "venv/lib/$py_folder/site-packages/"

db2_binary = $(ls ibm_db.cpython * | head - n 1)
echo "$db2_binary"
install_name_tool - change libdb2.dylib "$(pwd)/clidriver/lib/libdb2.dylib" "$db2_binary"

if test - f "$PWD/clidriver/lib/libdb2.dylib"; then
rm - rf libdb2.dylib
fi

ln - s "/usr/local/lib/$py_folder/site-packages/clidriver/lib/libdb2.dylib" libdb2.dylib
export DYLD_LIBRARY_PATH = "venv/lib/$py_folder/site-packages/clidriver/lib:$DYLD_LIBRARY_PATH"
```

After this, you should successfully be able to connect to DB2 via Python.

Note, I’ve only had this issue when using Python 3.7 and python 3.8. Testing with Python 3.9,  I don’t have this problem, and don’t need to run this script. Your results may vary

***

## Connecting to IBM DB2 on MacOS (M1 / Apple Silicon) with Python

The steps for this are a bit more complicated an very easy to get wrong unfortunately

1. Reinstall homebrew, but the x86 compatible version of homebrew! The explanation for why this is needed is on the [python-ibmdb page](https://github.com/ibmdb/python-ibmdb#pre-requisites). You might need to [uninstall](https://alexo.dev/bin/bash%20-c%20%22$\(curl%20-fsSL%20https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh\)%22) your current version of homebrew first

```shell
# Uninstall current version of homebrew
  / bin / bash - c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Install the x86 - compatible version of homebrew
arch - x86_64 / bin / bash - c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/usr/local/bin/brew shellenv)"
```

1. Install the x86 compatible version of Python you want.

```shell
arch - x86_64 brew install python @3.x
```

1. Make sure you’re using a virtual environment. Similar to the Intel instructions, virtual environments help isolate packages between projects

```shell
# Double check this is the python version you're wanting to use
python3--version

# Move to your project folder
cd project_folder

# Create the virtual environment in your project folder
python3 - m venv venv
```

1. Activate your virtual environment

```shell
source venv / bin / activate
```

1. Test the ibm\_db package works.  If it works in the python REPL, then it should work when actually run. You should not expect any return value if it is working properly!

```shell
python3 - c "import ibm_db" # Should not return anything!
```
