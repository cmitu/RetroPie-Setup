#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function onstart_flycast_joystick() {
    # Save the intermediary mappings into a temporary file
    truncate --size 0 /tmp/flycast-input-analog.ini
    truncate --size 0 /tmp/flycast-input-digital.ini
}

function map_flycast_joystick() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    # a hashmap to map 'es_input_name'=>'flycast_input_or_action_name'
    declare -A input_map=(
                      [up]="btn_dpad1_up"
                    [down]="btn_dpad1_down"
                    [left]="btn_dpad1_left"
                   [right]="btn_dpad1_right"
                       [a]="btn_a"
                       [b]="btn_b"
                       [x]="btn_x"
                       [y]="btn_y"
                   [start]="btn_start"
                  [select]="btn_menu"

            [hotkeyenable]="btn_menu"

            [leftshoulder]="btn_trigger_left"
             [lefttrigger]="btn_trigger2_left"
           [rightshoulder]="btn_trigger_right" 
            [righttrigger]="btn_trigger2_right"

          [leftanalogleft]="btn_analog_left"
         [leftanalogright]="btn_analog_right"
            [leftanalogup]="btn_analog_up"
          [leftanalogdown]="btn_analog_down"

         [rightanalogleft]="axis2_left"
        [rightanalogright]="axis2_right"
           [rightanalogup]="axis2_up"
         [rightanalogdown]="axis2_down"
    )
    # map between ES hat values and flycast's values
    declare -A hat_map=(
        [1]=256 # up
        [2]=259 # right
        [4]=257 # down
        [8]=258 # left
    )
    local emu_input_value
    local emu_input_name

    emu_input_name=${input_map[$input_name]}
    # if the mapped action/input is not defined, exit
    [[ -z "$emu_input_name" ]] && return 

    case "$input_type" in
       axis)
           # axis are considered analog inputs
           if [[ $input_value == "-1" ]]; then
               emu_input_value="$input_id-"
           else
               emu_input_value="$input_id+"
           fi
           echo "$emu_input_value for ${input_map[$input_name]} ($input_name) is analog"
           echo "$emu_input_value:$emu_input_name" >> /tmp/flycast-input-analog.ini
           ;; 
       hat)
           # hat inputs are treated like buttons, but with some calculation
           emu_input_value=${hat_map[$input_value]}
           echo "$emu_input_value for ${input_map[$input_name]} ($input_name, value $input_value) is digital hat"
           echo "$emu_input_value:$emu_input_name" >> /tmp/flycast-input-digital.ini
           ;;
       button)
           emu_input_value="$input_id"
           echo "$emu_input_value for ${input_map[$input_name]} ($input_name) is digital"
           echo "$emu_input_value:$emu_input_name" >> /tmp/flycast-input-digital.ini
           ;;
       *)
           ;;
     esac
}

function onend_flycast_joystick() {
    local cfg="$configdir/dreamcast/mappings/SDL_${DEVICE_NAME//[:><?\"\/\\|*]/-}.cfg"
    local i
    local line

    mkdir -p `dirname "$cfg"`

    # save the analog inputs first
    echo "[analog]" > "$cfg"
    i=0
    while read line; do
        echo "bind$i = $line" >> "$cfg"
        i="$((i+1))"
    done < <(sort /tmp/flycast-input-analog.ini | uniq)
    echo >> "$cfg"

    # the digital inputs
    i=0
    echo "[digital]" >> "$cfg"
    while read line; do
        echo "bind$i = $line" >> "$cfg"
        i="$((i+1))"
    done < <(sort /tmp/flycast-input-digital.ini | uniq)
    echo  >> "$cfg"

    # add the mapping name at the end
    echo "[emulator]" >> "$cfg"
    echo "mapping_name = ${DEVICE_NAME//[:><?\"\/\\|*]/-}" >> "$cfg"
}
