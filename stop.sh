#!/usr/bin/env bash

# Cores e Estilos para saída premium
export BOLD='\033[1m'
export PURPLE='\033[38;2;141;124;255m'
export CYAN='\033[38;2;0;240;255m'
export GREEN='\033[38;2;40;167;69m'
export YELLOW='\033[38;2;255;193;7m'
export RED='\033[38;2;220;53;69m'
export RESET='\033[0m'

clear

echo -e "${PURPLE}${BOLD}===================================================================${RESET}"
echo -e "${PURPLE}${BOLD}                   ⚡ ENCERRANDO INFRA HERMES OS ⚡                ${RESET}"
echo -e "${PURPLE}${BOLD}===================================================================${RESET}"
echo ""

# 1. Verificar se o K3d está disponível
if ! command -v k3d &> /dev/null; then
    if [ -f "./bin/k3d" ]; then
        K3D_BIN="./bin/k3d"
    else
        echo -e "${RED}${BOLD}[ERRO] K3d não foi encontrado no PATH nem em ./bin/k3d!${RESET}"
        exit 1
    fi
else
    K3D_BIN="k3d"
fi

# 2. Fechar conexões de Port-Forward do ArgoCD
echo -e "${CYAN}🧹  Encerrando conexões de Port-Forward ativas...${RESET}"
PF_PID=$(pgrep -f "port-forward.*argocd-server.*8085")
if [ -n "$PF_PID" ]; then
    kill -9 "$PF_PID" > /dev/null 2>&1
    echo -e "${GREEN}✅  Túnel do ArgoCD (PID: $PF_PID) encerrado com sucesso!${RESET}"
else
    echo -e "${GREEN}✅  Nenhum túnel de Port-Forward ativo para encerrar.${RESET}"
fi

# 3. Parar o Cluster K3d
CLUSTER_NAME="dev-cluster"
CLUSTER_RUNNING=$($K3D_BIN cluster list | grep -w "$CLUSTER_NAME" | grep -v "0/1" | grep -v "stopped")

if [ -n "$CLUSTER_RUNNING" ]; then
    echo -e "${CYAN}🛑  Parando cluster K3d '${CLUSTER_NAME}'...${RESET}"
    $K3D_BIN cluster stop "$CLUSTER_NAME"
    echo -e "${GREEN}✅  Cluster '${CLUSTER_NAME}' parado com sucesso!${RESET}"
else
    echo -e "${GREEN}✅  O cluster K3d '${CLUSTER_NAME}' já está parado ou não existe.${RESET}"
fi

# 4. Checagem Extra: Status Real dos Containers Docker
echo ""
echo -e "${CYAN}🔍  Checagem Extra: Status Real dos Containers Docker...${RESET}"
DOCKER_CONTAINERS=$(docker ps -a --filter name="k3d-$CLUSTER_NAME-" --format "{{.Names}}::{{.Status}}")

if [ -n "$DOCKER_CONTAINERS" ]; then
    printf "   ${BOLD}%-35s %s${RESET}\n" "CONTAINER DOCKER" "STATUS REAL"
    echo -e "   ------------------------------------------------------------"
    echo "$DOCKER_CONTAINERS" | while read -r line; do
        name=$(echo "$line" | cut -d':' -f1)
        status=$(echo "$line" | cut -d':' -f3-)
        
        if [[ "$status" =~ "Exited" ]]; then
            printf "   %-35s ${RED}⏹️  %s${RESET}\n" "$name" "$status"
        elif [[ "$status" =~ "Up" ]]; then
            printf "   %-35s ${GREEN}▶️  %s${RESET}\n" "$name" "$status"
        else
            printf "   %-35s ${YELLOW}⏳  %s${RESET}\n" "$name" "$status"
        fi
    done
else
    echo -e "   ${YELLOW}Nenhum container Docker associado ao '${CLUSTER_NAME}' encontrado.${RESET}"
fi

echo ""
echo -e "${PURPLE}${BOLD}===================================================================${RESET}"
echo -e "${GREEN}${BOLD}             🎉 INFRAESTRUTURA DESATIVADA COM SUCESSO!            ${RESET}"
echo -e "${PURPLE}${BOLD}===================================================================${RESET}"
echo -e "   Até logo, David! Toda a sua pilha DevOps está devidamente pausada."
echo -e "${PURPLE}${BOLD}===================================================================${RESET}"

