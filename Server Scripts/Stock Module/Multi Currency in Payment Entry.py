# Useful မဖြစ်ရင် ဖျက်ပါမယ်။

# Script Type: DocType Event
# DocType Event: Before Save

# Apply USD payment rule only once on creation, not on every save (Payment Entry)
if doc.references and len(doc.references) > 0:
    ref = doc.references[0]

    if ref.reference_doctype == "Purchase Invoice" and ref.reference_name:
        pi = frappe.get_doc("Purchase Invoice", ref.reference_name)

        # Only enforce defaults on NEW Payment Entry, not after user edits
        if doc.is_new() and pi.currency == "MMK":

            # Set Paid From account
            doc.paid_from = "Cash MMK"
            doc.paid_from_account_currency = "MMK"

            # Set initial paid amount (one-time only)
            doc.paid_amount = pi.grand_total

            # Auto-calc received amount
            if doc.source_exchange_rate:
                doc.received_amount = doc.paid_amount * doc.source_exchange_rate

        # If user edits paid_amount manually, DO NOT override it here
