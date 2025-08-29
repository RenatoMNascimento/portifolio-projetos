CREATE DATABASE OlistBI;
GO
USE OlistBI;

CREATE TABLE stg_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME,
);


--MODELO DIMENSIONAL
-- DIMENSÃO CLIENTE
CREATE TABLE DimCliente (
    ClienteID VARCHAR(50) PRIMARY KEY,
    CEP VARCHAR(20),
    Cidade VARCHAR(100),
    Estado VARCHAR(2)
);

INSERT INTO DimCliente
SELECT DISTINCT
    customer_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM stg_customers;

-- DIMENSÃO PRODUTO
CREATE TABLE DimProduto (
    ProdutoID VARCHAR(50) PRIMARY KEY,
    Categoria VARCHAR(100),
    NomeCategoriaTraduzido VARCHAR(100)
);

INSERT INTO DimProduto
SELECT 
    p.product_id,
    p.product_category_name,
    t.product_category_name_english
FROM stg_products p
LEFT JOIN stg_product_category_name_translation t
    ON p.product_category_name = t.product_category_name;

-- DIMENSÃO VENDEDOR
CREATE TABLE DimVendedor (
    VendedorID VARCHAR(50) PRIMARY KEY,
    CEP VARCHAR(20),
    Cidade VARCHAR(100),
    Estado VARCHAR(2)
);

INSERT INTO DimVendedor
SELECT DISTINCT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM stg_sellers;

-- DIMENSÃO PEDIDO
CREATE TABLE DimPedido (
    PedidoID VARCHAR(50) PRIMARY KEY,
    ClienteID VARCHAR(50),
    DataCompra DATETIME,
    StatusPedido VARCHAR(30)
);

INSERT INTO DimPedido
SELECT DISTINCT
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_status
FROM stg_orders;

-- DIMENSÃO TEMPO
CREATE TABLE DimTempo (
    Data DATE PRIMARY KEY,
    Ano INT,
    Mes INT,
    Dia INT,
    DiaSemana VARCHAR(20),
    NomeMes VARCHAR(20)
);

-- Geração baseada nos timestamps dos pedidos
INSERT INTO DimTempo
SELECT DISTINCT
    CAST(order_purchase_timestamp AS DATE) AS Data,
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp),
    DAY(order_purchase_timestamp),
    DATENAME(WEEKDAY, order_purchase_timestamp),
    DATENAME(MONTH, order_purchase_timestamp)
FROM stg_orders;


-- FATO VENDAS
CREATE TABLE FatoVendas (
    PedidoID VARCHAR(50),
    ProdutoID VARCHAR(50),
    VendedorID VARCHAR(50),
    NumeroItem INT,
    DataPedido DATE,
    Preco FLOAT,
    Frete FLOAT,
    PRIMARY KEY (PedidoID, NumeroItem),
    FOREIGN KEY (PedidoID) REFERENCES DimPedido(PedidoID),
    FOREIGN KEY (ProdutoID) REFERENCES DimProduto(ProdutoID),
    FOREIGN KEY (VendedorID) REFERENCES DimVendedor(VendedorID),
    FOREIGN KEY (DataPedido) REFERENCES DimTempo(Data)
);

INSERT INTO FatoVendas (
    PedidoID,
    ProdutoID,
    VendedorID,
    DataPedido,
    Preco,
    Frete,
    NumeroItem
)
SELECT
    i.order_id,
    i.product_id,
    i.seller_id,
    CAST(o.order_purchase_timestamp AS DATE),
    i.price,
    i.freight_value,
    i.order_item_id  -- <-- incluir esta coluna
FROM stg_order_items i
JOIN stg_orders o ON i.order_id = o.order_id
WHERE EXISTS (
    SELECT 1 FROM DimProduto dp WHERE dp.ProdutoID = i.product_id
)
AND EXISTS (
    SELECT 1 FROM DimVendedor dv WHERE dv.VendedorID = i.seller_id
)
AND EXISTS (
    SELECT 1 FROM DimPedido dped WHERE dped.PedidoID = i.order_id
)
AND EXISTS (
    SELECT 1 FROM DimTempo dt WHERE dt.Data = CAST(o.order_purchase_timestamp AS DATE)
);

--RENOMEANDO TABELAS
EXEC sp_rename 'stg_product', 'stg_products';
EXEC sp_rename 'stg_product_category_name_translation', 'stg_product_category_name';

--Descobrir quais product_id estão faltando
-- ProdutoID que estão em stg_order_items mas não existem em DimProduto:
SELECT DISTINCT i.product_id
FROM stg_order_items i
LEFT JOIN DimProduto p ON i.product_id = p.ProdutoID
WHERE p.ProdutoID IS NULL;


-- Verificar vendedor_id inválido
SELECT DISTINCT i.seller_id
FROM stg_order_items i
LEFT JOIN DimVendedor v ON i.seller_id = v.VendedorID
WHERE v.VendedorID IS NULL;

-- Verificar order_id inválido
SELECT DISTINCT i.order_id
FROM stg_order_items i
LEFT JOIN DimPedido p ON i.order_id = p.PedidoID
WHERE p.PedidoID IS NULL;

select * from FatoVendas;



SELECT COUNT(*) AS Produtos_Faltando
FROM stg_order_items i
WHERE i.product_id NOT IN (SELECT ProdutoID FROM DimProduto);

SELECT COUNT(*) AS Vendedores_Faltando
FROM stg_order_items i
WHERE i.seller_id NOT IN (SELECT VendedorID FROM DimVendedor);

SELECT COUNT(*) AS Vendedores_Faltando
FROM stg_order_items i
WHERE i.seller_id NOT IN (SELECT VendedorID FROM DimVendedor);

SELECT COUNT(*) AS Pedidos_Faltando
FROM stg_order_items i
WHERE i.order_id NOT IN (SELECT PedidoID FROM DimPedido);

SELECT COUNT(*) AS Datas_Faltando
FROM stg_orders o
WHERE CAST(o.order_purchase_timestamp AS DATE) NOT IN (SELECT Data FROM DimTempo);

-- Recria a DimProduto com tradução opcional
DELETE FROM DimProduto;

INSERT INTO DimProduto
SELECT 
    p.product_id,
    p.product_category_name,
    ISNULL(t.Column2, 'Sem Tradução') AS NomeCategoriaTraduzido
FROM stg_products p
LEFT JOIN stg_product_category_name t
    ON p.product_category_name = t.Column1;


   EXEC sp_rename 'stg_product_category_name_translation.Column1', 'product_category_name', 'COLUMN';
EXEC sp_rename 'stg_product_category_name_translation.Column2', 'product_category_name_english', 'COLUMN';



