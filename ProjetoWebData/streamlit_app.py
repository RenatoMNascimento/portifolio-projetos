import streamlit as st
import requests
import pandas as pd
import plotly.express as px

# df = pd.read_csv('../DADOS_TRATADOS/Dados_coletados.csv')

from sqlalchemy import create_engine 
engine = create_engine('sqlite:///banco.db', echo=True)

# try:
#     df.to_sql('dados', con=engine, if_exists='replace', index=False)
#     print("Tabela 'dados' criada e dados inseridos com sucesso!")
# except Exception as e:
#     print("Erro ao criar a tabela no banco de dados:", e)

try:
    df_lido = pd.read_sql('SELECT * FROM dados', con=engine)
    print("Dados lidos do banco com sucesso:")
    print(df_lido)
except Exception as e:
    print("Erro ao ler os dados do banco:", e)


st.write("Dados carregados do banco de dados", df_lido)

st.write("Histograma de Preços")
fig_hist = px.histogram(df_lido.precos) # type: ignore
st.plotly_chart(fig_hist)

st.write("Gráfico de pizza, preços")
fig_pie = px.pie(df_lido, "precos") # type: ignore
st.plotly_chart(fig_pie)

st.write("Barra de Preços")
fig_bar = px.bar(df_lido, 'precos') # type: ignore
st.plotly_chart(fig_bar)

st.write("Barra de Preços por Produto")
fig_bar2 = px.bar(df_lido, x='precos', y='produto', color='agrup1') # type: ignore
st.plotly_chart(fig_bar2)

st.write("Scatter de Preços por Produto")
fig_scar = px.scatter(df_lido, x='precos', y='produto', color='agrup1') # type: ignore
st.plotly_chart(fig_scar)

st.write("Histograma de Preços por Produto")
fig_hist2 = px.histogram(df_lido, x='produto', y='precos', color='agrup1') # type: ignore
st.plotly_chart(fig_hist2)

media = df_lido['precos'].mean()
mediana = df_lido['precos'].median()
desvio_padrao = df_lido['precos'].std()

st.write(f'Média dos Preços: {media:.2f}')
st.write(f'Mediana dos Preços: {mediana:.2f}')
st.write(f'Desvio Padrão dos Preços: {desvio_padrao:.2f}')
