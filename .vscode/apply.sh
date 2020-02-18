#!/usr/bin/env bash

function get_script_dir() {
  [ -z "${BASH_SOURCE[0]}" ] && {
    >&2 echo 'BASH_SOURCE[0] is empty'
    return 1
  }
  local __old_dir=$(pwd)
  local __source="${BASH_SOURCE[0]}" __dir=
  while [ -h "${__source}" ]
  do
    __dir=$(dirname "${__source}")
    __dir="$(cd -P "${__dir}" >/dev/null 2>&1 && pwd)"
    __source="$(readlink "$__source")"
    [[ ${__source} != /* ]] && {
      __source="$(readlink "$__source")"
    }
  done
  __dir=$(dirname "${__source}")
  __dir="$(cd -P "${__dir}" >/dev/null 2>&1 && pwd)"
  cd "${__old_dir}"
  echo ${__dir}
  return 0
}

function get_script_name() {
  [ ! -z "${BASH_SOURCE[0]}" ] && {
    echo $(basename "${BASH_SOURCE[0]}")
    return 0
  }
  echo $(basename "$0")
  return 0
}

function main() {
  local __old_dir=$(pwd)
  __old_dir=$(realpath "${__old_dir}")
  local __script_name= __script_dir=
  __script_name=$(get_script_name)
  __script_dir=$(get_script_dir)


  local red='\e[0;31m'
  local green='\e[0;32m'
  local nocolor='\e[0m'
  local redbold='\e[1;31m'
  local greenbold='\e[1;32m'
  local nocolorbold='\e[1m'

  local __cmd_args=( "$@" )

  local __funcmsg=       # set `__funcerror` variable with custom message 
  local __funccanceled=0 # if you want to cancel script set to `1`
  local __funcresult=1   # set `__funcresult` variable with script result
  
  while true
  do  
    local vscode_user_global_snippets_path="${HOME}/.config/Code/User/snippets"
    [ -d "$vscode_user_global_snippets_path" ] || {
      local __funcmsg=${redbold}"cannot find VSCode global snippets path ${vscode_user_global_snippets_path} of user ${USER}"
      break
    }
    local __repo_dir="${__script_dir}/.."
    __repo_dir=$(realpath "${__repo_dir}")
    __funcmsg=$(find "${__repo_dir}" -maxdepth 1 -type f -name '*.json' -printf "%f\n"|xargs -I RR -n1 ${SHELL} -c 'local filename=RR && filename=${filename%.*} && cp "'${__repo_dir}'/$filename.json" "'${vscode_user_global_snippets_path}'/booldog-$filename.code-snippets"' 2>&1) || {
      __funcmsg=${redbold}${__funcmsg}
      break
    }
    __funcresult=0
    break
  done  
  
  cd "${__old_dir}"

  while true
  do
    [ ! -z "$__funcmsg" ] && {
      [ $__funcresult -eq 0 ] && {
        echo -e "${__funcmsg}${nocolor}"

      } || {
        echo -e "${__funcmsg}${nocolor}" 1>&2
      }
      break
    }

    [ $__funccanceled -eq 1 ] && {
      echo -e ${redbold}${__script_name}${red}' is canceled'${nocolor} 1>&2
      break
    }   
    
    [ $__funcresult -eq 0 ] || {        
      echo -e ${redbold}${__script_name}${red}' is failed'${nocolor} 1>&2
    }
    break
  done

  [ "${BASH_SOURCE[0]}" = "$0" ] && {
    exit $__funcresult
  } || {
    return $__funcresult
  }  
}
main "$@"