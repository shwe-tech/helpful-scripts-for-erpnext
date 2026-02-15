-- Explanation: Show the detals items of purchase receipt

-- Requirements
-- ** Add "from_date" & "to_date" filters

SELECT
    pr.posting_date            AS "Posting Date:Date:110",
    pr.name                    AS "Purchase Receipt:Link/Purchase Receipt:200",
    pr.supplier_name           AS "Supplier Name:Data:200",

    pri.item_code              AS "Item Code:Link/Item:180",
    pri.item_name              AS "Item Name:Data:250",

    pri.qty                    AS "Quantity:Float:100",

    /* Currency information */
    pr.currency                AS "Currency:Link/Currency:90",
    pr.conversion_rate         AS "Exchange Rate:Float:110",

    /* Document currency values (numeric only) */
    pri.rate                   AS "Rate:Float:120",
    pri.net_amount             AS "Net Amount:Float:150",

    /* Base currency (MMK) total */
    (pri.net_amount * pr.conversion_rate)
                               AS "Net Amount (MMK):Float:180",

    pri.cost_center            AS "Cost Center:Link/Cost Center:200"

FROM
    `tabPurchase Receipt` pr
INNER JOIN
    `tabPurchase Receipt Item` pri
        ON pr.name = pri.parent

WHERE
    pr.docstatus = 1
    AND pr.posting_date BETWEEN %(from_date)s AND %(to_date)s

ORDER BY
    pr.posting_date,
    pr.name;
