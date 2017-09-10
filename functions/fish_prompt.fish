function __print_color
    set -l color  $argv[1]
    set -l string $argv[2]

    set_color $color
    printf $string
    set_color normal
end

function __git_upstream_configured
    git rev-parse --abbrev-ref @"{u}" > /dev/null 2>&1
end

function fish_prompt -d "Tricoder's fish prompt"
    echo -e ""
    set -l pwd_path (prompt_pwd)
    __print_color $fish_color_cwd "$pwd_path"

    if set -l branch_name (git_branch_name)
        set -l branch_status

        if git_is_dirty
            set branch_status "*"
        else
            set branch_status "+"
        end

        echo -sn (set_color -o) " ($branch_name$branch_status) " (set_color normal)

        if __git_upstream_configured
             set -l git_ahead (command git rev-list --left-right --count HEAD...@"{u}" ^ /dev/null | awk '
                $1 > 0 { printf("⇡") } # can push
                $2 > 0 { printf("⇣") } # can pull
             ')

             if test ! -z "$git_ahead"
                __print_color $fish_color_git " $git_ahead"
            end
        end
    end

    printf "\e[K\n❯ "
end
