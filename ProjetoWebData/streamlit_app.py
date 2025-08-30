
import streamlit as st
import pandas as pd
import plotly.express as px
from sqlalchemy import create_engine
import os

st.set_page_config(page_title="Dashboard de Preços", layout="wide")

# Caminho do CSV
csv_path = 'Dados_coletados.csv'

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
            # Criar a tabela no SQLite
            df_lido.to_sql('dados', con=engine, if_exists='replace', index=False)
            st.success("Tabela 'dados' criada com sucesso a partir do CSV!")
        except Exception as e:
            st.error(f"Erro ao criar a tabela 'dados' a partir do CSV: {e}")
            df_lido = None
    else:
        st.error(f"Arquivo CSV '{csv_path}' não encontrado.")
        df_lido = None

# Só prosseguir se df_lido existir e não estiver vazio
if df_lido is not None and not df_lido.empty:
    st.write("### Dados carregados do banco de dados")
    st.dataframe(df_lido)

    # Histograma de Preços
    if 'precos' in df_lido.columns:
        st.write("### Histograma de Preços")
        fig_hist = px.histogram(df_lido, x='precos')
        st.plotly_chart(fig_hist, use_container_width=True)

    # Gráfico de pizza de Preços
    if 'precos' in df_lido.columns:
        st.write("### Gráfico de Pizza de Preços")
        fig_pie = px.pie(df_lido, names='precos')
        st.plotly_chart(fig_pie, use_container_width=True)

    # Barra de Preços
    if 'precos' in df_lido.columns:
        st.write("### Barra de Preços")
        fig_bar = px.bar(df_lido, x='precos')
        st.plotly_chart(fig_bar, use_container_width=True)

    # Barra de Preços por Produto
    if all(col in df_lido.columns for col in ['precos', 'produto', 'agrup1']):
        st.write("### Barra de Preços por Produto")
        fig_bar2 = px.bar(df_lido, x='precos', y='produto', color='agrup1')
        st.plotly_chart(fig_bar2, use_container_width=True)

    # Scatter de Preços por Produto
    if all(col in df_lido.columns for col in ['precos', 'produto', 'agrup1']):
        st.write("### Scatter de Preços por Produto")
        fig_scar = px.scatter(df_lido, x='precos', y='produto', color='agrup1')
        st.plotly_chart(fig_scar, use_container_width=True)

    # Histograma de Preços por Produto
    if all(col in df_lido.columns for col in ['produto', 'precos', 'agrup1']):
        st.write("### Histograma de Preços por Produto")
        fig_hist2 = px.histogram(df_lido, x='produto', y='precos', color='agrup1')
        st.plotly_chart(fig_hist2, use_container_width=True)

    # Estatísticas básicas
    if 'precos' in df_lido.columns:
        media = df_lido['precos'].mean()
        mediana = df_lido['precos'].median()
        desvio_padrao = df_lido['precos'].std()

        st.write(f"**Média dos Preços:** {media:.2f}")
        st.write(f"**Mediana dos Preços:** {mediana:.2f}")
        st.write(f"**Desvio Padrão dos Preços:** {desvio_padrao:.2f}")
else:
    st.info("Nenhum dado disponível para exibir.")
