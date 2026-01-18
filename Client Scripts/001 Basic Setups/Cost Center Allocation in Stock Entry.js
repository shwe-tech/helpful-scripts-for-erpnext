// Entry ရဲ့ Form မှာ Cost Center ကို ရွေးတာနဲ့ Item Table ထဲမှာရှိတဲ့ Cost Center တွေ အလိုလျောက်ရွေးချယ်စေပါတယ်။
// Default Function အရ Form မှာ Cost Center ကို အပြောင်းအလဲလုပ်ရင် Table ရဲ့ Entry တွေမှာ Effect မရှိတဲ့အတွက်ကြောင့်ဖြစ်ပါတယ်။

frappe.ui.form.on("Stock Entry", {
    custom_cost_center: function(frm) {
        if (frm.doc.custom_cost_center) {
            frm.doc.items.forEach(function(row) {
                frappe.model.set_value(row.doctype, row.name, "cost_center", frm.doc.custom_cost_center);
            });
            frm.refresh_field("items");
        }
    }
});

frappe.ui.form.on("Stock Entry Detail", {
    items_add: function(frm, cdt, cdn) {
        if (frm.doc.custom_cost_center) {
            frappe.model.set_value(cdt, cdn, "cost_center", frm.doc.custom_cost_center);
        }
    }
});

frappe.ui.form.on('Stock Entry Detail', {
	refresh(frm) {
		// your code here
	}
})