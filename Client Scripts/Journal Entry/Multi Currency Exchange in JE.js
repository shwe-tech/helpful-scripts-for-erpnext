// JE မှာ Custom Field ထည့်ပြီး Amount တစ်ခုရိုက်ထည့်တာနဲ့ Account Entry Table မှာ Exchange Rate Auto ကျ


frappe.ui.form.on('Journal Entry', {
    refresh(frm) {
        set_exchange_rate(frm);
    },

    custom_exchange_rate(frm) {
        set_exchange_rate(frm);
    }
});

frappe.ui.form.on('Journal Entry Account', {
    account(frm, cdt, cdn) {
        set_exchange_rate(frm);
    },

    debit_in_account_currency(frm, cdt, cdn) {
        set_exchange_rate(frm);
    },

    credit_in_account_currency(frm, cdt, cdn) {
        set_exchange_rate(frm);
    }
});

function set_exchange_rate(frm) {
    if (!frm.doc.custom_exchange_rate || frm.doc.custom_exchange_rate <= 0) {
        return;
    }

    const base_currency = frm.doc.company_currency || "USD";
    const custom_rate = flt(frm.doc.custom_exchange_rate);

    (frm.doc.accounts || []).forEach(row => {
        if (!row.account || !row.account_currency) return;

        // BASE currency account
        if (row.account_currency === base_currency) {
            if (row.exchange_rate !== 1) {
                frappe.model.set_value(
                    row.doctype,
                    row.name,
                    "exchange_rate",
                    1
                );
            }
        }
        // FOREIGN currency account (MMK)
        else {
            const rate = flt(1 / custom_rate, 8); // 0.00022222

            if (row.exchange_rate !== rate) {
                frappe.model.set_value(
                    row.doctype,
                    row.name,
                    "exchange_rate",
                    rate
                );
            }
        }
    });

    frm.refresh_field("accounts");
}


frappe.ui.form.on('Journal Entry Account', {
	refresh(frm) {
		// your code here
	}
})