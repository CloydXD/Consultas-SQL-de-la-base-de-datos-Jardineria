-- 1. Listar información básica de las oficinas
SELECT codigo_oficina, ciudad, pais, telefono
FROM oficina;

-- 2. Obtener los empleados por oficina
SELECT codigo_oficina, nombre, apellido1, apellido2, puesto
FROM empleado
ORDER BY codigo_oficina;

-- 3. Calcular el promedio de salario (límite de crédito) de los clientes por región
SELECT region, AVG(limite_credito) AS promedio_limite_credito
FROM cliente
GROUP BY region;

-- 4. Listar clientes con sus representantes de ventas
SELECT c.nombre_cliente,
       CONCAT(e.nombre, ' ', e.apellido1, ' ', COALESCE(e.apellido2, '')) AS representante_ventas
FROM cliente c
LEFT JOIN empleado e
ON c.codigo_empleado_rep_ventas = e.codigo_empleado;

-- 5. Obtener productos disponibles y en stock
SELECT codigo_producto, nombre, cantidad_en_stock
FROM producto
WHERE cantidad_en_stock >= 1;

-- 6. Productos con precios por debajo del promedio
SELECT nombre, precio_venta
FROM producto
WHERE precio_venta < (
    SELECT AVG(precio_venta)
    FROM producto
);

-- 7. Pedidos pendientes por cliente
SELECT p.codigo_pedido, p.estado, c.nombre_cliente
FROM pedido p
JOIN cliente c
ON p.codigo_cliente = c.codigo_cliente
WHERE p.estado != 'Entregado';

-- 8. Total de productos por categoría (gama)
SELECT gama, COUNT(codigo_producto) AS total_productos
FROM producto
GROUP BY gama;

-- 9. Ingresos totales generados por cliente
SELECT c.nombre_cliente,
       SUM(pa.total) AS ingresos_totales
FROM cliente c
JOIN pago pa
ON c.codigo_cliente = pa.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente;

-- 10. Pedidos realizados en un rango de fechas
SELECT codigo_pedido, fecha_pedido
FROM pedido
WHERE fecha_pedido BETWEEN '2008-01-01' AND '2008-12-31';

-- 11. Detalles de un pedido específico
SELECT codigo_pedido,
       codigo_producto,
       cantidad,
       precio_unidad,
       (cantidad * precio_unidad) AS precio_total_linea
FROM detalle_pedido
WHERE codigo_pedido = 1;

-- 12. Productos más vendidos
SELECT p.nombre,
       SUM(dp.cantidad) AS cantidad_total_vendida
FROM detalle_pedido dp
JOIN producto p
ON dp.codigo_producto = p.codigo_producto
GROUP BY dp.codigo_producto, p.nombre
ORDER BY cantidad_total_vendida DESC;

-- 13. Pedidos con un valor total superior al promedio
SELECT codigo_pedido,
       SUM(cantidad * precio_unidad) AS valor_total
FROM detalle_pedido
GROUP BY codigo_pedido
HAVING SUM(cantidad * precio_unidad) > (
    SELECT AVG(total_pedido)
    FROM (
        SELECT SUM(cantidad * precio_unidad) AS total_pedido
        FROM detalle_pedido
        GROUP BY codigo_pedido
    ) AS promedios
);

-- 14. Clientes sin representante de ventas asignado
SELECT nombre_cliente
FROM cliente
WHERE codigo_empleado_rep_ventas IS NULL;

-- 15. Número total de empleados por oficina
SELECT codigo_oficina,
       COUNT(codigo_empleado) AS total_empleados
FROM empleado
GROUP BY codigo_oficina;

-- 16. Pagos realizados en una forma específica
SELECT *
FROM pago
WHERE forma_pago = 'PayPal';

-- 17. Ingresos mensuales
SELECT YEAR(fecha_pago) AS anio,
       MONTH(fecha_pago) AS mes,
       SUM(total) AS ingresos_mes
FROM pago
GROUP BY YEAR(fecha_pago), MONTH(fecha_pago)
ORDER BY anio, mes;

-- 18. Clientes con múltiples pedidos
SELECT c.nombre_cliente,
       COUNT(p.codigo_pedido) AS total_pedidos
FROM cliente c
JOIN pedido p
ON c.codigo_cliente = p.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
HAVING COUNT(p.codigo_pedido) > 1;

-- 19. Pedidos con productos agotados
SELECT DISTINCT dp.codigo_pedido
FROM detalle_pedido dp
JOIN producto p
ON dp.codigo_producto = p.codigo_producto
WHERE p.cantidad_en_stock = 0;

-- 20. Promedio, máximo y mínimo del límite de crédito por país
SELECT pais,
       AVG(limite_credito) AS promedio_credito,
       MAX(limite_credito) AS max_credito,
       MIN(limite_credito) AS min_credito
FROM cliente
GROUP BY pais;

-- 21. Historial de transacciones de un cliente
SELECT fecha_pago,
       total,
       forma_pago
FROM pago
WHERE codigo_cliente = 1
ORDER BY fecha_pago;

-- 22. Empleados sin jefe directo asignado
SELECT nombre,
       apellido1,
       apellido2,
       puesto
FROM empleado
WHERE codigo_jefe IS NULL;

-- 23. Productos cuyo precio supera el promedio de su categoría
SELECT p1.nombre,
       p1.gama,
       p1.precio_venta
FROM producto p1
WHERE p1.precio_venta > (
    SELECT AVG(p2.precio_venta)
    FROM producto p2
    WHERE p1.gama = p2.gama
);

-- 24. Promedio de días de entrega por estado
SELECT estado,
       AVG(DATEDIFF(fecha_entrega, fecha_pedido)) AS promedio_dias_entrega
FROM pedido
WHERE fecha_entrega IS NOT NULL
GROUP BY estado;

-- 25. Clientes por país con más de un pedido
SELECT c.pais,
       COUNT(c.codigo_cliente) AS clientes_con_multiples_pedidos
FROM cliente c
WHERE c.codigo_cliente IN (
    SELECT codigo_cliente
    FROM pedido
    GROUP BY codigo_cliente
    HAVING COUNT(codigo_pedido) > 1
)
GROUP BY c.pais;