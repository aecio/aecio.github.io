---
title: Análise de dados usando Elasticsearch Aggregations
author: Aécio Santos
permalink: /2015/06/08/analise-de-dados-usando-elasticsearch-aggregations/
#published_time: June 8, 2015
published_time: 2015-06-08T19:05:18+00:00
modified_time:  2015-06-09T02:03:58+00:00
content_type: markdown
extra:
  content_class: "blog-post"
---
# Análise de dados usando Elasticsearch Aggregations
*June 8, 2015*

<img class="img-fluid" src="{{site.base_url}}/static/img/elasticsearch.png" alt="Elasticsearch logo">

O [Elasticsearch](https://www.elastic.co/products/elasticsearch) é uma ferramenta que surgiu inicialmente com intenção de ser uma máquina de busca distribuída desenvolvida em cima da biblioteca [Apache Lucene](http://lucene.apache.org/). Ao longo do tempo, com a adição de novas features, foram surgindo diferentes casos de uso da ferramenta que vão muito além da busca textual para qual foi inicialmente desenvolvida.

## Agregações

A partir da versão 1.0, o Elasticsearch lançou uma feature que permite agregações de dados. [Agregações](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html) são computações feitas em cima dos documentos retornados por alguma consulta. Por exemplo, dado um conjunto de documentos que casam com uma consulta, é possivel computar quais são os termos mais frequentes, quantos documentos caem em uma determinada faixa de tempo, quais documentos estão dentro de uma distância geográfica, e por ai vai.

No Elasticsearch existem diversass implementações de agregações disponíveis que podem ser classificadas em duas categorias:

- **Bucketing aggregations** – Permitem o agrupamento dos documentos resultantes de uma consulta em partições de acordo com valores extraídos dos documentos. O resultado final de uma agregação será uma lista de buckets, cada um contendo um subconjunto dos documentos da consulta. Dependendo da agregração utilizada, um bucket pode ser um intervalo numérico, um intervalo de datas, um termo, um raio de distância geográfica, etc.
- **Metrics aggregations** – Agregações de métricas computam valores a partir de um documento, sejam extraíndo o valor diretamente do documento, ou realizando alguma computação em cima de valores extraídos dos documentos.

Uma das características mais importantes das agregações é que elas podem ser aninhadas, ou seja, você pode computar agregações em cima dos resultados de outras agregações, como veremos nos exemplos mais a frente.

Agregrações tem a seguinte estrutura básica:

```
"aggregations" : {
    "<aggregation_name>" : {
        "<aggregation_type>" : {
            <aggregation_body>
        }
        [,"aggregations" : { [<sub_aggregation>]+ } ]?
    }
    [,"<aggregation_name_2>" : { ... } ]*
}
```
onde: `aggregation_name` é um nome qualquer escolhido por você para identificar uma agregação, `aggregation_type` é o tipo da agregação (como por ex: *min, max, avg, stats, terms, geo_distance, etc.*), `aggregation_body` são os parâmetros da agregação e `aggregations` é um array (opcional) de agregações aninhadas que irão operar sobre os resultados da agregação definida no nível acima. As subagregações definidas no array *aggregations* também podem ter subagregações aninhadas. Não há um número máximo para a quantidade de agregações aninhadas.

## Exemplo de uso de agregações com dados reais

Para esse exemplo, vamos utilizar dados sobre os candidatos a Deputado Estadual e Federal do estado de Minas Gerais nas Eleições de 2014. Os dados estão disponíveis no site do TSE [neste link](http://www.tse.jus.br/eleicoes/eleicoes-2014/sistema-de-divulgacao-de-candidaturas) (também disponível em formato CSV). Também dá pra visualizar a lista completa [aqui](http://g1.globo.com/politica/eleicoes/2014/mg/candidatos-deputado-federal.html) (deputados federais) e [aqui](http://g1.globo.com/politica/eleicoes/2014/mg/candidatos-deputado-estadual.html) (deputados estaduais).

Inicialmente os dados precisam ser indexados no Elasticsearch. Para isso, vamos organizar os dados em documento JSON da seguinte forma:
```
{
  "partido": "PARTIDO",
  "nome": "NOME DO CANDIDATO",
  "numero": 99999,
  "coligacao": "PARTIDO1 / PARTIDO2 / PARTIDO3"
}
```

Mas antes de indexar os documentos, vamos criar [mappings](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping.html) para informar explicitamente ao Elasticsearch que o texto de alguns campos não deve ser pré-processado. Por padrão, o Elasticsearch realiza um processo de análise de texto que envove quebra o texto em termos, tranformação de caracteres em minúsculas, remoção de sufixos, e outros. A criação de mappings no Elasticsearch pode ser comparada a definição do esquema de uma tabela em um banco de dados relacional, porém no Elasticsearch este passo é opcional.

O objetivo de criar os mappings nesse exemplo é somente para evitar o comportamento padrão do Elasticsearch, que é fazer pre-processamento do texto antes de indexar. Para isso, vamos mapear os campos `partido` e `coligacao` do documento JSON como "não analizados".

Vamos indexar cada tipo de candidato em tipos diferentes no Elasticsearch: `dep_federal` e `dep_estadual`, como comando cURL a seguir:
```
curl -XPUT 'http://localhost:9200/eleicoes2014' -d '{
   "mappings": {
      "dep_federal": {
         "properties": {
            "partido": {
               "type": "string",
               "index": "not_analyzed"
            },
            "coligacao": {
               "type": "string",
               "index": "not_analyzed"
            },
            "numero": {
               "type": "integer"
            }
         }
      },
      "dep_estadual": {
         "properties": {
            "partido": {
               "type": "string",
               "index": "not_analyzed"
            },
            "coligacao": {
               "type": "string",
               "index": "not_analyzed"
            },
            "numero": {
               "type": "integer"
            }
         }
      }
   }
}'
```

Para indexar os documentos precisamos enviar os documentos em requisições POST para a [API de indexação do Elasticsearch](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-index_.html). Para esse exemplo, implementei isso usando JavaScript e *Node.js*. O códido para cada arquivo está aqui [https://github.com/aecio/presentations/blob/master/sample/estadual.js](https://github.com/aecio/presentations/blob/master/sample/estadual.js) e aqui [https://github.com/aecio/presentations/blob/master/sample/federal.js](https://github.com/aecio/presentations/blob/master/sample/federal.js). Além da API REST, existem bibliotecas diponíveis para diversas linguagens de programação.

## Análise exploratória de dados usando agregações

Finalmente podemos fazer uma análise exploratória nos dados. Vamos começar com uma pergunta bem simples. *Há quantos cadidatos de cada tipo?* A seguinte agregação responde essa pergunta:
```
curl -XPOST "http://localhost:9200/eleicoes2014/_search" -d'
{
   "size": 0,
   "aggregations": {
      "tipo_de_candidato": {
         "terms": {
            "field": "_type"
         }
      }
   }
}'
```

Neste exemplo, estamos executando uma agregação que identificamos como `tipo_de_candidato`. Essa agregação é do tipo `terms`, que agrupa os documentos em grupos (*buckets*) para cada termo distinto encontrado. Como parâmetro, informamos que a agregação seja feita usando o campo `_type`, que é um campo especial presente em todos os documentos indexados e que armazena o tipo do documento. Como nós indexamos somente dois tipos de documentos, são retornados dois buckets contentdo a quantidade de documentos em cada bucket:

```
{
   "took": 2,
   "timed_out": false,
   "_shards": {
      "total": 5,
      "successful": 5,
      "failed": 0
   },
   "hits": {
      "total": 1898,
      "max_score": 0,
      "hits": []
   },
   "aggregations": {
      "tipo_de_candidato": {
         "buckets": [
            {
               "key": "dep_estadual",
               "doc_count": 1200
            },
            {
               "key": "dep_federal",
               "doc_count": 698
            }
         ]
      }
   }
}
```

Note que como não especificamos nenhuma *query* para o Elasticsearch, a agregação operou em todos os documentos indexados (1898 hits). Se quiséssemos fazer uma pergunta mais específica, como por exemplo: **Há quantos cadidatos de cada tipo que se chamam João?** Nesse caso, poderíamos fazer a seguinte agregação:

```
curl -XPOST "http://localhost:9200/eleicoes2014/_search?q=nome:joao" -d'
{
   "size": 0,
   "aggregations": {
      "tipo_de_candidato": {
         "terms": {
            "field": "_type"
         }
      }
   }
}'
```

Note a adição da query **q=nome:joao** no final da URL da requisição. Esta query retorna somente 8 caditados com o termo joao no nome, os quais são agregados em dois buckets:

```
{
   "took": 12,
   "timed_out": false,
   "_shards": {
      "total": 5,
      "successful": 5,
      "failed": 0
   },
   "hits": {
      "total": 8,
      "max_score": 0,
      "hits": []
   },
   "aggregations": {
      "tipo_de_candidato": {
         "buckets": [
            {
               "key": "dep_estadual",
               "doc_count": 6
            },
            {
               "key": "dep_federal",
               "doc_count": 2
            }
         ]
      }
   }
}
```

Suponha agora que precisamos de mais detalhes. Para cada tipo de cadidato, precisamos saber:

- Quais as duas coligações que tem mais candidatos?
- Quais os dois partidos que tem mais candidatos?
- Quais os valores minimo, máximo e médio dos números dos cadidatos?

Podemos reponder todas essas pergutas somente com uma requisição, utilizando agregações aninhadas:

```
curl -XPOST "http://localhost:9200/eleicoes2014/_search" -d'
{
   "size": 0,
   "aggregations": {
      "tipo_de_candidato": {
         "terms": {
            "field": "_type"
         },
         "aggregations": {
            "por_partido": {
               "terms": {
                  "field": "partido",
                  "size": 2
               }
            },
            "por_coligacao": {
               "terms": {
                  "field": "coligacao",
                  "size": 2
               }
            },
            "estatisticas_de_numero": {
               "stats": {
                  "field": "numero"
               }
            }
         }
      }
   }
}'
```

Nessa agregação utilizamos a mesma agregação do primeiro exemplo, com adição de 3 subagregações, uma para cada pergunta. A agregação `por_partido` fará agregação de termos usando os valores do campo `partido`, a agregação `por_coligacao` fará agregação utilizando o campo `coligacao`, e a agregação `estatisticas_de_numero`, que é do tipo `stats`, retornará estatísticas sumarizando os números encontrados no campo número. A reposta para essa agregação pode ser vista a seguir:

```
{
   "took": 6,
   "timed_out": false,
   "_shards": {
      "total": 5,
      "successful": 5,
      "failed": 0
   },
   "hits": {
      "total": 1898,
      "max_score": 0,
      "hits": []
   },
   "aggregations": {
      "tipo_de_candidato": {
         "buckets": [
            {
               "key": "dep_estadual",
               "doc_count": 1200,
               "por_coligacao": {
                  "buckets": [
                     {
                        "key": "PRP / PEN / PHS",
                        "doc_count": 133
                     },
                     {
                        "key": "PT / PROS / PMDB / PRB",
                        "doc_count": 108
                     }
                  ]
               },
               "por_partido": {
                  "buckets": [
                     {
                        "key": "PT do B",
                        "doc_count": 85
                     },
                     {
                        "key": "PC do B",
                        "doc_count": 41
                     }
                  ]
               },
               "estatisticas_de_numero": {
                  "count": 1200,
                  "min": 10000,
                  "max": 90999,
                  "avg": 36122.61666666667,
                  "sum": 43347140
               }
            },
            {
               "key": "dep_federal",
               "doc_count": 698,
               "por_coligacao": {
                  "buckets": [
                     {
                        "key": "PTdo B / PRP / PHS / PEN",
                        "doc_count": 81
                     },
                     {
                        "key": "DEM / PSDB / PP / PR / PSD / SD",
                        "doc_count": 47
                     }
                  ]
               },
               "por_partido": {
                  "buckets": [
                     {
                        "key": "PT do B",
                        "doc_count": 55
                     },
                     {
                        "key": "PSB",
                        "doc_count": 37
                     }
                  ]
               },
               "estatisticas_de_numero": {
                  "count": 698,
                  "min": 1000,
                  "max": 9090,
                  "avg": 3420.3409742120343,
                  "sum": 2387398
               }
            }
         ]
      }
   }
}
```

## Conclusão

Neste post vimos como o Elasticsearch pode ser uma ferramenta que vai muito além de busca textual. A nova funcionalidade de agregação de dados permite realização de consultas *ad-hoc* aos dados, possibilitando a exploração de grande bases de dados com pouco esforço de programação. O tipos de agregações disponíveis no Elasticsearch vão muito além das utilizadas nesse post. Existem agregações por distância geográfica, faixas de IPv4, percentis, histogramas, faixas de data, e etc, que ainda podem ser combinadas com os diversos tipos de queries e filtros disponíveis. Veja lá na [documentação](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html) a lista de agregações disponíveis.

<!-- Se alguma coisa tiver ficado muito confusa, deixem as dúvidas nos comentários que vou tentando esclarecer e melhorar o post. -->

Até a próxima! 🙂
