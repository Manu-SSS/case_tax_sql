-- Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500
SELECT 
    c.ID_Customer, 
    c.Nombre, 
    c.Apellido
FROM 
    MELI_CUSTOMER c
JOIN 
    MELI_ORDER o ON c.ID_Customer = o.ID_Customer
JOIN 
    MELI_ORDER_ITEM oi ON o.ID_Order = oi.ID_Order
JOIN 
    MELI_ITEM i ON oi.ID_Item = i.ID_Item
WHERE 
    EXTRACT(MONTH FROM c.Fecha_Nacimiento) = EXTRACT(MONTH FROM CURRENT_DATE())
    AND EXTRACT(DAY FROM c.Fecha_Nacimiento) = EXTRACT(DAY FROM CURRENT_DATE())
    AND EXTRACT(MONTH FROM o.Fecha) = 1
    AND EXTRACT(YEAR FROM o.Fecha) = 2020
    AND i.ID_Seller = c.ID_Customer
GROUP BY 
    c.ID_Customer, c.Nombre, c.Apellido
HAVING 
    COUNT(o.ID_Order) > 1500;

-- Top 5 usuarios que más vendieron($) en la categoría Celulares por cada mes del 2020
SELECT 
    Año,
    Mes,
    Nombre,
    Apellido,
    Cantidad_Ventas,
    Cantidad_Productos,
    Monto_Total
FROM (
    SELECT
        EXTRACT(YEAR FROM o.Fecha) AS Año,
        EXTRACT(MONTH FROM o.Fecha) AS Mes,
        c.Nombre,
        c.Apellido,
        COUNT(o.ID_Order) AS Cantidad_Ventas,
        SUM(oi.Cantidad) AS Cantidad_Productos,
        SUM(oi.Cantidad * oi.Precio_Unitario) AS Monto_Total,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM o.Fecha), EXTRACT(MONTH FROM o.Fecha) ORDER BY SUM(oi.Cantidad * oi.Precio_Unitario) DESC) AS row_num
    FROM 
        MELI_CUSTOMER c
    JOIN 
        MELI_ITEM i ON c.ID_Customer = i.ID_Seller
    JOIN 
        MELI_ORDER_ITEM oi ON i.ID_Item = oi.ID_Item
    JOIN 
        MELI_ORDER o ON oi.ID_Order = o.ID_Order
    JOIN 
        MELI_CATEGORY cat ON i.ID_Category = cat.ID_Category
    WHERE 
        cat.Path LIKE 'Tecnología > Celulares y Teléfonos > Celulares y Smartphones%'
        AND EXTRACT(YEAR FROM o.Fecha) = 2020
    GROUP BY 
        Año, Mes, c.ID_Customer, c.Nombre, c.Apellido
)
WHERE 
    row_num <= 5;


-- Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. 
CREATE OR REPLACE TABLE MELI_ITEM_SNAPSHOT AS
SELECT 
    ID_Item,
    Precio,
    CASE 
        WHEN Fecha_Baja IS NULL THEN 'Activo'
        ELSE 'Inactivo'
    END AS Estado,
    CURRENT_DATETIME() AS Snapshot_Date
FROM 
    MELI_ITEM;
