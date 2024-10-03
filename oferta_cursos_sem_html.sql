SELECT TOP 1 C.CategoryID, O.CreationDate, SK.ProductName
FROM dt_Order AS O
INNER JOIN dt_OrderItem OI 
ON CONCAT('00-',O.OrderId) = OI.OrderId
INNER JOIN dt_Sku SK 
ON OI.SkuId = SK.Id
INNER JOIN dt_Product P
ON SK.ProductID = P.ProductID
INNER JOIN dt_Category C
ON P.CategoryID = C.CategoryID
WHERE O.Email = @email
ORDER BY O.CreationDate DESC

-----------------------------------------------------------

SELECT TOP 1 IdCategoria, Curso, Aula, Link
FROM dt_Aulas AS A
WHERE A.IdCategoria = @categoria
ORDER BY NEWID()

-----------------------------------------------------------

/*

<var curso="GetRowsByTemplate('getClassByLastPurchasedProductCategory', new [] { new Param('email', SubscriberEmail) })"/>

<if condition="curso.Count > 0">
  <p>Olá, vimos que seu último produto comprado foi da categoria <b>(${curso[0]['IdCategoria']}) - ${curso[0]['Categoria']}</b>.</p>
  <p>Viemos então oferecer o curso <b>${curso[0]['Curso']}</b> relacionado à área, cuja aula <b>${curso[0]['Aula']}</b> poderá te interessar.</p>
  <p>Acesse a sua aula agora: <a href="${curso[0]['Link']}" target="_blank" style="padding: 5px; background-color: yellow; border-radius: 10px; border-style: solid;">Aula</a></p>
</if>

*/

-- ########################################################

-- getCourseToWhomBoughtSkusAreNotInAulas
---- BasedOnTheLastPurchasedProductCategory
/*
	Para cada destinatário o qual nenhuma de suas compras possui Sku na tabela Aulas, enviar uma mensagem oferecendo um curso da tabela Aulas o qual pertença à mesma categoria de seu último produto comprado
*/

SELECT IdCategoria, C.Name AS Categoria, Curso, Aula, Link
FROM dt_Aulas AS A
JOIN dt_Category C ON C.CategoryId = A.IdCategoria
-- JOIN dt_Product P ON P.CategoryId = C.CategoryId
WHERE A.IdCategoria = (
   SELECT TOP 1 C.CategoryID
   FROM dt_Order AS O
   INNER JOIN dt_OrderItem OI 
   ON CONCAT('00-',O.OrderId) = OI.OrderId
   INNER JOIN dt_Sku SK 
   ON OI.SkuId = SK.Id
   INNER JOIN dt_Product P
   ON SK.ProductID = P.ProductID
   INNER JOIN dt_Category C
   ON P.CategoryID = C.CategoryID
   WHERE O.Email IN (
                     SELECT @email FROM dt_Order AS O 
                     INNER JOIN dt_OrderItem OI 
                     ON CONCAT('00-',O.OrderId) = OI.OrderId
                     INNER JOIN dt_Sku SK 
                     ON OI.SkuId = SK.Id
                     INNER JOIN dt_Product P
                     ON SK.ProductID = P.ProductID
                     INNER JOIN dt_Category C
                     ON P.CategoryID = C.CategoryID
                     INNER JOIN dt_Aulas A ON C.CategoryId = A.IdCategoria
                     WHERE 
                     OI.SkuId NOT IN (SELECT IdSku FROM dt_Aulas)
                    )
                   
   ORDER BY O.CreationDate DESC
) 

