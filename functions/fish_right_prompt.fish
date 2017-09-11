function fish_right_prompt
  set -l last_command_status $status

  if test $last_command_status != 0
    set_color red
    printf "$last_command_status ↵ "
    set_color normal
  end

  printf (date "+%H:%M:%S")
end
