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

function __git_tag
    git tag -l --points-at HEAD 2>/dev/null
end

function fish_prompt -d "Tricoder's fish prompt"
    set -l __glyph_branch " \uf407 "

    set -l python_virtualenv (basename "$VIRTUAL_ENV")
    if test -n $python_virtualenv
      __print_color $fish_color_python "$python_virtualenv \ue606 "
    end

    set -l pwd_path (prompt_pwd)
    __print_color $fish_color_cwd "$pwd_path"

    if set -l branch_local (git_branch_name)
        set -l branch_remote
        set -l branch_delimiter
        set -l branch_name (git rev-parse --abbrev-ref HEAD 2>/dev/null)

        set -l is_detached ""
        if [ $branch_name = "HEAD" ]
          set is_detached "\uf127 "
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
            set -l commit_behind (string trim $commit_count[3])

            set -l git_action
            if test $commit_ahead -gt 0 -a $commit_behind -gt 0
                # need merge
                set git_action '\uf402'
            else if test $commit_ahead -gt 0
                # need push
                set git_action '\uf40a'
            else if test $commit_behind -gt 0
                # need fast forward
                set git_action '\uf102'
            else
                # all good!
                set git_action '\uf113'
            end


            if test $commit_ahead -gt 0
              set commit_ahead " +$commit_ahead"
            else
              set commit_ahead ""
            end

            if test $commit_behind -gt 0
              set commit_behind "-$commit_behind "
            else
              set commit_behind ""
            end

            __print_color $fish_color_git " $commit_behind$git_action$commit_ahead"
        end

        __print_color $fish_color_git " $is_detached($branch_local$branch_delimiter$branch_remote)"

        # Show Git tag for current commit
        # If there're more than one tag, show the first and multiple tag icon
        set -l git_tags (__git_tag)
        set -l git_tags_count (count $git_tags)

        if test $git_tags_count -gt 0
            # Single tag icon
            set -l git_tag_icon "\uf02b"

            if test $git_tags_count -gt 1
              # Multiple tags icon
              set git_tag_icon "\uf02c"
            end

            __print_color $fish_color_git " $git_tag_icon $git_tags[1]"
        end
    end

    printf "\e[K\n\uf105 "
end
