# controller/pesquisador_controller.py
from fastapi import APIRouter, HTTPException
from typing import List
from model.pesquisador import Pesquisador
from controller.dao.pesquisador_dao import (
    apagar_por_lattes_id,
    listar_todos,
    salvar_novo_pesquisador,
    atualizar_por_id
)

# Criação de um router chamado 'pesquisador_router'
pesquisador_router = APIRouter()

# Rota para salvar um novo pesquisador
@pesquisador_router.post("/pesquisadores", response_model = Pesquisador)
def adicionar(pesquisador: Pesquisador):
    resposta = salvar_novo_pesquisador(
        nome = pesquisador.nome,
        lattes_id = pesquisador.lattes_id,
        pesquisador_id=pesquisador.pesquisadores_id

       
    )
    
    if 'duplicate' in resposta:
        raise HTTPException(status_code=409, detail=resposta)
    if 'Erro' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return pesquisador

# Rota para listar todos os pesquisadores
@pesquisador_router.get("/pesquisadores", response_model = List[Pesquisador])
def listar():
    pesquisadores = listar_todos()
    return pesquisadores

# Rota para apagar um pesquisador com base no lattes_id
@pesquisador_router.delete("/pesquisadores/{lattes_id}", response_model=str)
def apagar(lattes_id: str):
    print("chegou aqui")
    resposta = apagar_por_lattes_id(lattes_id)
    
    if 'inválido' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return resposta

# Rota para atualizar um pesquisador com base no lattes_id
@pesquisador_router.put("/pesquisadores/{lattes_id}", response_model=Pesquisador)
def atualizar(lattes_id: str, pesquisador: Pesquisador):
    resposta = atualizar_por_id(
        nome = pesquisador.nome,
        pesquisadores_id = pesquisador.pesquisadores_id,
        lattes_id = pesquisador.lattes_id
    )
    
    if 'Erro' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return pesquisador
