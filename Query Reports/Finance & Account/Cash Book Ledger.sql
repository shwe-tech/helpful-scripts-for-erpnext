SELECT * FROM (

    /* =======================
       1️⃣ OPENING ROW
       ======================= */
    SELECT
        '' AS "Ref.#:Data:180",
        '' AS "Voucher Type:Data:120",
        NULL AS "Date:Date:120",
        '' AS "Description:Data:180",
        NULL AS "Exchange Rate:Float:80",
        NULL AS "Amount:Float:120",
        'Opening' AS "Currency:Data:80",

        /* Opening Debit */
        CASE 
            WHEN opening_balance > 0 THEN opening_balance
            ELSE 0
        END AS "Debit:Currency:120",

        /* Opening Credit */
        CASE 
            WHEN opening_balance < 0 THEN ABS(opening_balance)
            ELSE 0
        END AS "Credit:Currency:120",

        opening_balance AS "Balance:Currency:150",

        '' AS "Cash Account:Data:170",
        '' AS "Against Account:Data:170",
        '' AS "Cost Center:Data:120",
        0 AS sort_order

    FROM (
        SELECT IFNULL(SUM(gle.debit - gle.credit),0) AS opening_balance
        FROM `tabGL Entry` gle
        INNER JOIN `tabAccount` acc ON acc.name = gle.account
        WHERE acc.account_type = 'Cash'
        AND gle.is_cancelled = 0
        AND gle.posting_date < %(from_date)s
        AND (%(account)s IS NULL OR %(account)s = '' OR gle.account = %(account)s)
    ) ob


    UNION ALL


    /* =======================
       2️⃣ TRANSACTIONS
       ======================= */
    SELECT
        gle.voucher_no,
        gle.voucher_type,
        gle.posting_date,

        CASE 
            WHEN gle.voucher_type = 'Journal Entry' THEN je.custom_description
            WHEN gle.voucher_type = 'Payment Entry' THEN pe.custom_description
            ELSE ''
        END,

        gle.transaction_exchange_rate,

        (gle.debit_in_account_currency - gle.credit_in_account_currency)
            AS "Amount:Float:120",

        gle.account_currency,

        gle.debit AS "Debit:Currency:120",
        gle.credit AS "Credit:Currency:120",

        (
            ob.opening_balance
            +
            IFNULL((
                SELECT SUM(g2.debit - g2.credit)
                FROM `tabGL Entry` g2
                INNER JOIN `tabAccount` a2 ON a2.name = g2.account
                WHERE a2.account_type = 'Cash'
                AND g2.is_cancelled = 0
                AND g2.posting_date BETWEEN %(from_date)s AND gle.posting_date
                AND (%(account)s IS NULL OR %(account)s = '' OR g2.account = %(account)s)
            ),0)
        ) AS "Balance:Currency:150",

        gle.account,
        gle.against,
        gle.cost_center,
        1 AS sort_order

    FROM `tabGL Entry` gle
    INNER JOIN `tabAccount` acc ON acc.name = gle.account

    CROSS JOIN (
        SELECT IFNULL(SUM(gle.debit - gle.credit),0) AS opening_balance
        FROM `tabGL Entry` gle
        INNER JOIN `tabAccount` acc ON acc.name = gle.account
        WHERE acc.account_type = 'Cash'
        AND gle.is_cancelled = 0
        AND gle.posting_date < %(from_date)s
        AND (%(account)s IS NULL OR %(account)s = '' OR gle.account = %(account)s)
    ) ob

    LEFT JOIN `tabJournal Entry` je 
        ON je.name = gle.voucher_no 
        AND gle.voucher_type = 'Journal Entry'

    LEFT JOIN `tabPayment Entry` pe 
        ON pe.name = gle.voucher_no 
        AND gle.voucher_type = 'Payment Entry'

    WHERE acc.account_type = 'Cash'
    AND gle.is_cancelled = 0
    AND gle.posting_date BETWEEN %(from_date)s AND %(to_date)s
    AND (%(account)s IS NULL OR %(account)s = '' OR gle.account = %(account)s)


    UNION ALL


    /* =======================
       3️⃣ TOTAL ROW
       ======================= */
    SELECT
        '',
        '',
        NULL,
        '',
        NULL,
        NULL,
        'Total',

        SUM(gle.debit) AS "Debit:Currency:120",
        SUM(gle.credit) AS "Credit:Currency:120",
        SUM(gle.debit - gle.credit) AS "Balance:Currency:150",

        '',
        '',
        '',
        2 AS sort_order

    FROM `tabGL Entry` gle
    INNER JOIN `tabAccount` acc ON acc.name = gle.account
    WHERE acc.account_type = 'Cash'
    AND gle.is_cancelled = 0
    AND gle.posting_date BETWEEN %(from_date)s AND %(to_date)s
    AND (%(account)s IS NULL OR %(account)s = '' OR gle.account = %(account)s)


    UNION ALL


    /* =======================
       4️⃣ CLOSING ROW
       ======================= */
    SELECT
        '',
        '',
        NULL,
        '',
        NULL,
        NULL,
        'Closing',

        /* Closing Debit */
        (
            CASE WHEN opening_balance > 0 THEN opening_balance ELSE 0 END
            +
            total_debit
        ) AS "Debit:Currency:120",

        /* Closing Credit */
        (
            CASE WHEN opening_balance < 0 THEN ABS(opening_balance) ELSE 0 END
            +
            total_credit
        ) AS "Credit:Currency:120",

        closing_balance AS "Balance:Currency:150",

        '',
        '',
        '',
        3 AS sort_order

    FROM (
        SELECT
            /* Opening Net */
            IFNULL(SUM(CASE 
                WHEN gle.posting_date < %(from_date)s 
                THEN (gle.debit - gle.credit) 
                ELSE 0 END),0) AS opening_balance,

            /* Period Totals */
            IFNULL(SUM(CASE 
                WHEN gle.posting_date BETWEEN %(from_date)s AND %(to_date)s
                THEN gle.debit ELSE 0 END),0) AS total_debit,

            IFNULL(SUM(CASE 
                WHEN gle.posting_date BETWEEN %(from_date)s AND %(to_date)s
                THEN gle.credit ELSE 0 END),0) AS total_credit,

            /* Final Net Balance */
            IFNULL(SUM(CASE 
                WHEN gle.posting_date <= %(to_date)s
                THEN (gle.debit - gle.credit)
                ELSE 0 END),0) AS closing_balance

        FROM `tabGL Entry` gle
        INNER JOIN `tabAccount` acc ON acc.name = gle.account
        WHERE acc.account_type = 'Cash'
        AND gle.is_cancelled = 0
        AND gle.posting_date <= %(to_date)s
        AND (%(account)s IS NULL OR %(account)s = '' OR gle.account = %(account)s)

    ) summary

) AS final_result
ORDER BY sort_order, `Date:Date:120`;
