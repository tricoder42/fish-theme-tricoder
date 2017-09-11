function __print_color
    set -l color  $argv[1]
    set -l string $argv[2]

    set_color $color
    printf $string
    set_color normal
end

function __print_bold
    set -l string $argv[1]

    set_color -o
    printf $string
    set_color normal
end

function __git_upstream
    string split "/" -- (git rev-parse --abbrev-ref @"{u}" 2>&1)
end

function __git_commit_count
    string split "" (git rev-list --left-right --count HEAD...@"{u}" 2>&1)
end

function fish_prompt -d "Tricoder's fish prompt"
    set -l __glyph_branch " ᄉ"

    echo -e ""
    set -l pwd_path (prompt_pwd)
    __print_color $fish_color_cwd "$pwd_path"

    if set -l branch_local (git_branch_name)
        set -l branch_remote
        set -l branch_delimiter
        set -l branch_status

        if git_is_dirty
            set branch_status "*"
        else
            set branch_status "+"
        end

        if set -l git_upstream (__git_upstream)
            set branch_delimiter "$__glyph_branch"

            if [ "$git_upstream[2]" = $branch_local ]
                set branch_remote $git_upstream[1]
            else
                set branch_remote (string join "/" $git_upstream)
            end


            set -l commit_count (__git_commit_count)
            set -l commit_ahead (string trim $commit_count[1])
            if test $commit_ahead -gt 0
              set commit_ahead "+$commit_ahead"
            else
              set commit_ahead "--"
            end
            set -l commit_behind (string trim $commit_count[3])
            if test $commit_behind -gt 0
              set commit_behind "-$commit_behind"
            else
              set commit_behind "--"
            end

            __print_color $fish_color_git " $commit_behind | $commit_ahead"
        end

        __print_color $fish_color_git " ($branch_local$branch_delimiter$branch_remote)"
    end

    printf "\e[K\n❯ "
end
