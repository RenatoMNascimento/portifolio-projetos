import streamlit as st
import pandas as pd
import plotly.express as px
from sqlalchemy import create_engine
import os

st.set_page_config(page_title="Dashboard de Preços", layout="wide")

# Caminho do CSV (mesma pasta do app)
csv_path = os.path.join(os.path.dirname(__file__), "Dados_coletados.csv")

# Criação do engine SQLite
engine = create_engine('sqlite:///banco.db', echo=False)

# Inicializa df_lido
df_lido = None

# Tentar ler dados da tabela 'dados'
try:
    df_lido = pd.read_sql('SELECT * FROM dados', con=engine)
    if df_lido.empty:
        st.warning("A tabela 'dados' existe, mas está vazia. Tentando carregar do CSV...")
        df_lido = None
except Exception:
    st.info("Tabela 'dados' não encontrada. Tentando criar a partir do CSV...")

# Se não conseguiu ler do banco, tenta carregar do CSV
if df_lido is None:
    if os.path.exists(csv_path):
        try:
            df_lido = pd.read_csv(csv_path)
            df_lido.to_sql('dados', con=engine, if_exists='replace', index=False)
            st.success("Tabela 'dados' criada com sucesso a partir do CSV!")
        except Exception as e:
            st.error(f"Erro ao criar a tabela 'dados' a partir do CSV: {e}")
            df_lido = None
    else:
        st.warning("Arquivo CSV não encontrado. Criando dados fictícios para teste...")
        # Criar dataframe fictício
        df_lido = pd.DataFrame({
            "produto": ["Arroz", "Feijão", "Macarrão", "Óleo", "Açúcar"],
            "precos": [10.5, 8.2, 6.7, 15.0, 9.3],
            "agrup1": ["Alimento", "Alimento", "Alimento", "Cozinha", "Alimento"]
        })
        df_lido.to_sql('dados', con=engine, if_exists='replace', index=False)

# Só prosseguir se df
