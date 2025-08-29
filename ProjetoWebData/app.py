
import os
from flask import Flask, jsonify
import pandas as pdy 
from slqalchemy import create_engine

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'O site está no ar'

@app.route('/dados', methods=['GET'])
def obter_dados():
    try:
        df = pd.read_csv('../DADOS TRATADOS/Dados_coletados.csv', index_col=0, encoding='utf-8')
        df.fillna(0, inplace=True)
        dados_json = df.to_dict(orient='records')
        return jsonify(dados_json)
    except FileNotFoundError:
        return jsonify({'error': 'Arquivo CSV não encontrado.'}), 404

if __name__ == '__main__':
    try:
        if not os.getenv("FLASK_ENV"):
            app.run(debug=True)
    except SystemExit:
        pass