# controller/producoes_controller.py
from fastapi import APIRouter, HTTPException
from typing import List
from model.producao import Producao
from controller.dao.producoes_dao import (
    apagar_por_producao_id,
    listar_todos,
    salvar_nova_producao,
    atualizar_por_id
)

# Criação de um router chamado 'pesquisador_router'
producao_router = APIRouter()

# Rota para salvar um nova producao
@producao_router.post("/producoes", response_model = Producao)
def adicionar(producao: Producao):
    resposta = salvar_nova_producao(producao)
    
    if 'duplicate' in resposta:
        raise HTTPException(status_code=409, detail=resposta)
    if 'Erro' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return producao

# Rota para listar todos os pesquisadores
@producao_router.get("/producoes", response_model = List[Producao])
def listar():
    producoes = listar_todos()
    return producoes

# Rota para apagar um pesquisador com base no lattes_id
@producao_router.delete("/producoes/{producao_id}", response_model=str)
def apagar(producao_id: str):
    print("chegou aqui")
    resposta = apagar_por_producao_id(producao_id)
    
    if 'inválido' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return resposta

# Rota para atualizar uma produção com base em ID
@producao_router.put("/producaoes/", response_model=Producao)
def atualizar(producao: Producao):
    resposta = atualizar_por_id(producao
    )
    
    if 'Erro' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return producao
