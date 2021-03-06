#!/bin/bash
# Sets up the template submodule for the paper framework.
# Author: Jason Ziglar <jpz@vt.edu>

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
abs_dir="${dir}/.."

# Read in multimarkdown latex support repository location
repo="https://github.com/fletcher/peg-multimarkdown-latex-support.git"
while getopts ":c" opt; do
  case $opt in
    c) repo=$OPTARG;;
  esac
done

# If common doesn't exist, clone it now
if [ ! -d "${abs_dir}/common" ]; then
  if [ -n "$repo" ]; then
    cur_dir=`pwd`
    cd $abs_dir
    git clone $repo ./common
    cd $cur_dir
  fi
fi

case `uname` in
  Darwin) latex_dir="${HOME}/Library/texmf";;
  Linux) latex_dir="${HOME}/texmf";;
  CYGWIN_NT*) latex_dir="${HOME}/.config/texmf";;
  *) echo "This platform not yet supported."; exit 1;;
esac

mkdir -p "${latex_dir}"/tex/latex
mkdir -p "${latex_dir}"/bibtex

mmd_dir="${latex_dir}/tex/latex/mmd"
bst_dir="${latex_dir}/bibtex/bst"
bib_dir="${latex_dir}/bibtex/bib"

# Attempt to symlink Latex files
if [ -d "${latex_dir}"/tex/latex/mmd ]; then
  echo "Directories for LaTeX already exist, which is problematic. Please determine if the following directories are correct, or remove them and run again."
  echo $mmd_dir
  echo $bst_dir
  echo $bib_dir
else
  ln -s ${abs_dir}/common $mmd_dir
  ln -s ${abs_dir}/common $bst_dir
  ln -s ${abs_dir}/common $bib_dir
fi

# Inject environment variable for building these files. If this isn't set, none of this will work.
echo "Looking for dir ${abs_dir}"
mmdl_dir=`grep "${abs_dir}/templates" ~/.bashrc`
echo "Done"
#Environment variable not defined, inject one for this repository
if [ -z "$mmdl_dir" ]; then
  echo "Configuring .bashrc"
  echo "export TEXINPUTS=${abs_dir}/templates/.//:$TEXINPUTS:" >> ~/.bashrc
fi