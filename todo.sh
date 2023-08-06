#!/usr/bin/env bash

if [[ ! -z $XDG_CONFIG_HOME ]]; then
    CONFIG_PATH="$XDG_CONFIG_HOME"
else
    CONFIG_PATH="$HOME/.config"
fi

SAVE_FILE="$CONFIG_PATH/todo"
Tasks=()

function log() {
    echo "$0: $*"
}

function log_n() {
    echo -n "$0: $*"
}

function get_saved_tasks() {
    if [ -s "$SAVE_FILE" ]; then
        while read -r line; do
            Tasks+=("${line}")
        done < $SAVE_FILE
    fi
}

function save_tasks() {
    clear_tasks
    for task in "${Tasks[@]}"; do
        echo "${task}" >> $SAVE_FILE
    done
}

function clear_tasks() {
    cat /dev/null > $SAVE_FILE
}

function fmt_task() {
    echo "$*"
}

function print_tasks() {
    if [[ ${#Tasks[@]} -ge 1 ]]; then
        if [[ ${#Tasks[@]} -eq 1 ]]; then
            log There is 1 task.
        else
            log There are ${#Tasks[@]} tasks.
        fi
        for i in "${!Tasks[@]}"; do
            local task=$(fmt_task "${Tasks[i]}")
            echo "$i: ${task}"
        done
    fi
}

function add_task() {
    Tasks+=("$*")
    save_tasks
    log Created task: $*
}

function delete_task() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        if [[ -n "${Tasks[$1]}" ]]; then
            unset "Tasks[$1]"
            save_tasks
        else
            log That task doesn\'t exist
            print_tasks
        fi
    else
        log Invalid number passed.
    fi
}

# Create a save file if it doesn't yet exist
if [[ ! -f $SAVE_FILE ]]; then
    touch $SAVE_FILE
fi

# Fetch all saved tasks
get_saved_tasks

# Parse commands args
if [ $# -lt 1 ]; then
    print_tasks
else
    case $1 in
        list)
            print_tasks
            ;;
        add)
            if [[ $# -lt 2 ]]; then
                log_n "Name of new task: "
                read name
                add_task "${name}"
            else
                add_task "${@:2}"
            fi
            ;;
        clear)
            clear_tasks
            lgo "Cleared tasks"
            ;;
        done)
            if [[ $# -lt 2 ]]; then
                read -p "Which one (pass a number): " i
                delete_task $i
            else
                delete_task $2
            fi
            ;;
        *)
            log "Unknown command: $1"
            ;;
    esac
fi
