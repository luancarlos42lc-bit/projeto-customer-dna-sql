-- PROJETO: CUSTOMER DNA & ANÁLISE DE SAZONALIDADE
-- OBJETIVO: Mapear o comportamento do consumidor e segmentar domínios
-- BASE DE DADOS: AdventureWorks2017
-- AUTOR: Luan Carlos Santos da Costa

	SELECT  
	-- EXTRAÇÃO TEMPORAL (Uso de DATEPART e DATENAME para identificar sazonalidade)
DATEPART (YEAR,OrderDate    )    AS Ano           ,
DATENAME (month,OrderDate   )    AS Mês           ,
DATENAME (weekday,OrderDate )    AS Dia        ,

-- AUXILIAR DE POSIÇÃO (Identifica onde começa o domínio após o caractere @)
CHARINDEX('@', EmailAddress )    AS Posicao_Arroba,

--  TRATAMENTO DE STRING (Isola apenas o domínio do e-mail do cliente)
SUBSTRING(EmailAddress                            , CHARINDEX('@', EmailAddress )    + 1              , 
LEN      (EmailAddress)     )    AS DominioEmail  ,

-- MÉTRICAS FINANCEIRAS (Agregações matemáticas para consolidação de indicadores)
SUM      (TotalDue)              AS TotalFaturado ,
COUNT    (DISTINCT SalesOrderID) AS QtdPEDIDOS    ,
SUM(TotalDue) / 
COUNT(DISTINCT SalesOrderID)     AS TicketMedio  
,
-- REGRA DE NEGÓCIO (Categoriza os canais de atendimento em Corporativo ou Varejo)
    CASE 
WHEN SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress)) = 'adventure-works.com' 
THEN 'Corporativo'
ELSE 'Varejo (Final)'
END AS TipoCliente

-- JUNCÇÃO DE SETORES (Relacionamentos entre Tabelas de Vendas e Dados Pessoais)
	FROM 
Sales.SalesOrderHeader                           AS SS
INNER JOIN Sales.Customer                        AS SC
ON SC.CustomerID = SS.CustomerID
INNER JOIN Person.Person                         AS PP
ON SC.PersonID = PP.BusinessEntityID
INNER JOIN Person.EmailAddress                   AS PE
ON PP.BusinessEntityID = PE.BusinessEntityID

-- REGRAS DE AGRUPAMENTO (Obrigatório para manter a consistência dos dados agregados)
    GROUP BY 
DATEPART (YEAR, OrderDate)   ,
DATENAME (month, OrderDate)  ,
DATENAME (weekday, OrderDate),
CHARINDEX('@', EmailAddress) ,
SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress))
