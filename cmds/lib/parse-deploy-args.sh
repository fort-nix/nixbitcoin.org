push=
action=switch

for arg in "$@"; do
    case $arg in
        -p|--push)
            push=1
            ;;
        -n|--dry-run)
            action=dry-activate
            ;;
    esac
done
