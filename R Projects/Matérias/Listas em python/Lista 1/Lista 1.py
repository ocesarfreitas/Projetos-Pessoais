"""
Lista 1 - Laboratório de Econometria
Aluno: César Freitas Albuquerque
"""

import basedosdados as bd

# Query para selecionar, filtrar e unir as bases
query = ''' SELECT *    
            FROM  basedosdados.br_ibge_pnad.microdados_compatibilizados_domicilio AS dom
            LEFT JOIN basedosdados.br_ibge_pnad.microdados_compatibilizados_pessoa AS pes
            ON pes.id_domicilio = dom.id_domicilio
            WHERE pes.ano = 1995 AND dom.ano = 1995 '''

# Chave do projeto           
sProjectID = "double-balm-306418"

# Importando a base 
pnadpesdos1995 = bd.read_sql(query, billing_project_id=sProjectID)

# Escrevendo arquivo gerado em CSV
pnadpesdos1995.to_csv("PNAD_dompes_1995.csv", index = False)