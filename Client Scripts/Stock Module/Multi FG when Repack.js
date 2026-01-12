//  Stock Entry မှာ Repack လုပ်ရင် Multiple Finished Goods ရအောင် ထိန်းထားပါတယ်။
//  Server Script နဲ့ အတူတွဲသုံးပါ။ "Multiple FG when Repack.py"

frappe.ui.form.on('Stock Entry', {
    stock_entry_type(frm) {
        if (frm.doc.stock_entry_type === "Repack") {
            frm.doc.items.forEach(row => {
                if (row.t_warehouse) {
                    frappe.model.set_value(row.doctype, row.name, 'is_finished_item', 1);
                    frappe.model.set_value(row.doctype, row.name, 'is_scrap_item', 1);
                    frappe.model.set_value(row.doctype, row.name, 'set_basic_rate_manually', 1);
                }
            });
        }
    }
});

frappe.ui.form.on('Stock Entry Detail', {
    t_warehouse(frm, cdt, cdn) {
        if (frm.doc.stock_entry_type !== "Repack") return;

        let row = locals[cdt][cdn];

        if (row.t_warehouse) {
            frappe.model.set_value(cdt, cdn, 'is_finished_item', 1);
            frappe.model.set_value(cdt, cdn, 'is_scrap_item', 1);
            frappe.model.set_value(row.doctype, row.name, 'set_basic_rate_manually', 1);
        }
    },

    refresh(frm, cdt, cdn) {
        if (frm.doc.stock_entry_type !== "Repack") return;

        let row = locals[cdt][cdn];

        if (row && row.t_warehouse) {
            frappe.model.set_value(cdt, cdn, 'is_finished_item', 1);
            frappe.model.set_value(cdt, cdn, 'is_scrap_item', 1);
            frappe.model.set_value(row.doctype, row.name, 'set_basic_rate_manually', 1);
        }
    }
});


frappe.ui.form.on('Stock Entry Detail', {
	refresh(frm) {
		// your code here
	}
})