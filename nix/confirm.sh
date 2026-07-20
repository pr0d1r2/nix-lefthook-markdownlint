#!/usr/bin/env bash

export FRAGMENTS_DIR="@SET_AND_SETTING@/setting/integrations/lefthook"
export ASSEMBLE_SCRIPT="@SET_AND_SETTING@/setting/lib/assemble-lefthook.sh"
export DETECT_SCRIPT="@SET_AND_SETTING@/setting/lib/detect-fragments.sh"
export SETTING_SRC="@SETTING_SRC@"
export CONFIRM_SCRIPT="@SET_AND_SETTING@/lib/confirm.sh"
export CONFIRM_REV="@CONFIRM_REV@"

bash "$CONFIRM_SCRIPT"
