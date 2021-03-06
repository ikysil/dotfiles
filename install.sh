#!/usr/bin/env bash
#
# Modeled after https://github.com/holman/dotfiles/blob/master/Rakefile

# keep going when something fails
set +e

#set -x # debug

function fail() {
  echo "$@" 1>&2
  exit 1
}

function debug() {
  # echo "$@"
  echo -n "" >/dev/null
}

overwrite_all=false
backup_all=false

function relpath() {
  python3 -c "import os,sys;print(os.path.relpath(*(sys.argv[1:])))" "$@";
}

function install_symlinks() {
  srcdir="$1"
  if [ ! -d "$srcdir" ]; then
    fail "Source directory [$srcdir] not found"
  fi

  symlinks=$(find "$srcdir" -name "*.symlink")
  for file in $symlinks; do
    source=${file}
    debug $source
    target=$HOME/$(echo "${file#$srcdir/}" | sed -e "s/dot_/./g" | sed -e "s/.symlink//")
    debug $target

    overwrite=false
    backup=false

    if [ -e "$target" ] || [ -h "$target" ]; then
      if ! $overwrite_all && ! $backup_all; then
        while true; do
          echo "$target already exists"
          echo "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all "
          read answer
          case $answer in
          "s") continue 2 ;; # continue the outer for loop
          "S") break 2 ;;    # break out of the outer for loop
          "o")
            overwrite=true
            break
            ;;
          "O")
            overwrite_all=true
            break
            ;;
          "b")
            backup=true
            break
            ;;
          "B")
            backup_all=true
            break
            ;;
          *) continue ;;
          esac
        done
      fi

      if $overwrite || $overwrite_all; then
        rm $target
      fi

      if $backup || $backup_all; then
        mv -T --backup=numbered "$target" "$target.backup"
      fi
    fi

    echo "Installing $target"
    ln -s "$(relpath "$source" $(dirname "$target"))" "$target"
  done
}

install_symlinks "$PWD/hosts/$HOSTNAME"
install_symlinks "$PWD/shared"
