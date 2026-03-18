# Git — mostra branch atual no prompt
parse_git_branch() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (󰊢 \1)/'
}

# Atalhos Kubernetes
alias k=kubectl
alias kx=kubectx
alias kn=kubens
alias kgi='kubectl get pods -o custom-columns="POD:.metadata.name,READY:.status.containerStatuses[*].ready,IMAGE:.spec.containers[*].image" | awk '\''NR==1{print "POD","READY","IMAGE"; next} {split($2,a," "); r=0; for(i=1;i<=length(a);i++) if(a[i]=="true") r++; split($3,b,"/"); $3=b[length(b)]; print $1,r"/"length(a),$3}'\'' | column -t'
alias kgiecr='kubectl get pods -o custom-columns="POD:.metadata.name,READY:.status.containerStatuses[*].ready,IMAGE:.spec.containers[*].image" | awk '\''NR==1{print "POD","READY","IMAGE"; next} {split($2,a," "); r=0; for(i=1;i<=length(a);i++) if(a[i]=="true") r++; print $1,r"/"length(a),$3}'\'' | column -t'
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Cor do contexto k8s (vermelho=prod, verde=dev, amarelo=staging)
function kube_ps1_ctx_color() {
  local context
  context="$(kubectl config current-context 2>/dev/null)"
  case "$context" in
    *prod*|*prd*)           echo "red"    ;;
    *dev*|*local*|*k3d*)    echo "green"  ;;
    *staging*|*stg*|*hmg*)  echo "yellow" ;;
    *)                      echo "cyan"   ;;
  esac
}

function get_cluster_short() {
  echo "$1" | cut -d . -f1
}

export KUBE_PS1_CTX_COLOR_FUNCTION=kube_ps1_ctx_color
export KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
export KUBE_PS1_SYMBOL_ENABLE=true
export KUBE_PS1_SYMBOL_CUSTOM="k8s"
export KUBE_PS1_SYMBOL_PADDING=true
export KUBE_PS1_SYMBOL_COLOR=white
export KUBE_PS1_PREFIX="{ "
export KUBE_PS1_SUFFIX=" }"

source "/usr/local/share/kube-ps1/kube-ps1.sh"

# Prompt
PS1='\[\e[1;36m\]╭──┤ \[\e[1;35m\][\A]\[\e[0m\] \
\[\e[1;34m\]\w\[\e[0m\]\[\033[33m\]$(parse_git_branch)\[\033[00m\] $(kube_ps1)
\[\e[1;36m\]╰─\[\e[1;32m\]❯\[\e[0m\] '
