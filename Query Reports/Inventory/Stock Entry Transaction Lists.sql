-- Requirements --
-- *** Add "from_date" & "to_date" filters
-- *** Add "stock_entry_type" filter and set the 'select' options (e.g., Material Issue, Material Receipt)

SELECT
    se.name AS "ID:Link/Stock Entry:150",
    se.stock_entry_type AS "Stock Entry Type:Data:140",
    se.posting_date AS "Posting Date:Date:100",
    se.posting_time AS "Posting Time:Time:90",
    se.custom_cost_center AS "Cost Center (Header):Link/Cost Center:150",

    sed.s_warehouse AS "Source Warehouse:Link/Warehouse:150",
    sed.t_warehouse AS "Target Warehouse:Link/Warehouse:150",

    sed.item_code AS "Item Code:Link/Item:150",
    sed.item_name AS "Item Name:Data:180",
    sed.qty AS "Quantity:Float:100",
    sed.uom AS "UOM:Link/UOM:80",
    sed.basic_rate AS "Basic Rate:Currency:110",
    sed.amount AS "Amount:Currency:120",

    sed.cost_center AS "Cost Center (Item):Link/Cost Center:150"

FROM
    `tabStock Entry` se
INNER JOIN
    `tabStock Entry Detail` sed
    ON sed.parent = se.name

WHERE
    se.docstatus = 1
    AND se.posting_date BETWEEN %(from_date)s AND %(to_date)s
    AND (%(stock_entry_type)s IS NULL OR se.stock_entry_type = %(stock_entry_type)s)

ORDER BY
    se.posting_date DESC,
    se.posting_time DESC,
    se.name DESC
