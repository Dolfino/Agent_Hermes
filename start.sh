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
echo -e "${PURPLE}${BOLD}                   ⚡ INICIALIZANDO INFRA HERMES OS ⚡              ${RESET}"
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

# 2. Verificar se o Kubectl está disponível
if ! command -v kubectl &> /dev/null; then
    if [ -f "./bin/kubectl" ]; then
        KUBECTL_BIN="./bin/kubectl"
    else
        echo -e "${RED}${BOLD}[ERRO] Kubectl não foi encontrado no PATH nem em ./bin/kubectl!${RESET}"
        exit 1
    fi
else
    KUBECTL_BIN="kubectl"
fi

# 3. Gerenciar o Cluster K3d
CLUSTER_NAME="dev-cluster"
CLUSTER_EXISTS=$($K3D_BIN cluster list | grep -w "$CLUSTER_NAME")

if [ -z "$CLUSTER_EXISTS" ]; then
    echo -e "${CYAN}🛠️  Criando cluster local '${CLUSTER_NAME}' no K3d...${RESET}"
    $K3D_BIN cluster create "$CLUSTER_NAME" --servers 1 --agents 1 -p "8080:80@loadbalancer" -p "8443:443@loadbalancer"
else
    # Verificar se o cluster está parado
    CLUSTER_STOPPED=$($K3D_BIN cluster list | grep -w "$CLUSTER_NAME" | grep "0/1")
    if [ -n "$CLUSTER_STOPPED" ]; then
        echo -e "${CYAN}🚀  Iniciando cluster K3d '${CLUSTER_NAME}'...${RESET}"
        $K3D_BIN cluster start "$CLUSTER_NAME"
    else
        echo -e "${GREEN}✅  O cluster K3d '${CLUSTER_NAME}' já está rodando!${RESET}"
    fi
fi

# 4. Aguardar a API do Kubernetes responder
echo -e "${CYAN}⏳  Aguardando nodes do cluster ficarem prontos...${RESET}"
$KUBECTL_BIN wait --for=condition=Ready nodes --all --timeout=60s > /dev/null 2>&1

# 5. Gerenciar o Port-Forward do ArgoCD
echo -e "${CYAN}🔌  Configurando túnel (Port-Forward) do ArgoCD...${RESET}"

# Limpar port-forwards antigos se existirem na porta 8085
PF_PID=$(pgrep -f "port-forward.*argocd-server.*8085")
if [ -n "$PF_PID" ]; then
    echo -e "${YELLOW}🧹  Fechando conexões antigas do ArgoCD (PID: $PF_PID)...${RESET}"
    kill -9 "$PF_PID" > /dev/null 2>&1
fi

# Iniciar o port-forward em background
nohup $KUBECTL_BIN port-forward svc/argocd-server -n argocd 8085:443 --address 127.0.0.1 > /dev/null 2>&1 &
NEW_PF_PID=$!

# Aguardar a porta 8085 abrir
TIMEOUT=15
while [ $TIMEOUT -gt 0 ]; do
    if ss -tuln | grep -q "8085"; then
        break
    fi
    sleep 1
    let TIMEOUT=TIMEOUT-1
done

if ss -tuln | grep -q "8085"; then
    echo -e "${GREEN}✅  Túnel do ArgoCD estabelecido com sucesso! (PID: $NEW_PF_PID)${RESET}"
else
    echo -e "${YELLOW}⚠️  Aviso: O port-forward do ArgoCD está levando mais tempo para responder.${RESET}"
fi

echo ""
echo -e "${PURPLE}${BOLD}===================================================================${RESET}"
echo -e "${GREEN}${BOLD}              🎉 AMBIENTE HERMES OS INICIADO COM SUCESSO!         ${RESET}"
echo -e "${PURPLE}${BOLD}===================================================================${RESET}"
echo ""
echo -e "   🔗 ${BOLD}Console Hermes OS:${RESET}     ${CYAN}http://hermes.local:8080${RESET}"
echo -e "   🐙 ${BOLD}Painel do ArgoCD:${RESET}       ${CYAN}https://localhost:8085${RESET}"
echo ""
echo -e "   ${YELLOW}${BOLD}Nota:${RESET} Se for seu primeiro acesso ao ArgoCD, a senha de admin"
echo -e "   pode ser recuperada com o comando:"
echo -e "   ${CYAN}kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d${RESET}"
echo ""
echo -e "${PURPLE}${BOLD}===================================================================${RESET}"
