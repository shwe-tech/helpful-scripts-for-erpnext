// Entry ရဲ့ Form မှာ Cost Center ကို ရွေးတာနဲ့ Item Table ထဲမှာရှိတဲ့ Cost Center တွေ အလိုလျောက်ရွေးချယ်စေပါတယ်။
// Default Function အရ Form မှာ Cost Center ကို အပြောင်းအလဲလုပ်ရင် Table ရဲ့ Entry တွေမှာ Effect မရှိတဲ့အတွက်ကြောင့်ဖြစ်ပါတယ်။

frappe.ui.form.on("Sales Order", {
    cost_center: function(frm) {
        if (frm.doc.cost_center) {
            // Update cost center for all existing item rows
            (frm.doc.items || []).forEach(row => {
                if (row.cost_center !== frm.doc.cost_center) {
                    frappe.model.set_value(row.doctype, row.name, "cost_center", frm.doc.cost_center);
                }
            });
            frm.refresh_field("items");
        }
    },

    refresh: function(frm) {
        // Keep consistency on refresh
        if (frm.doc.cost_center) {
            frm.trigger("cost_center");
        }
    }
});

frappe.ui.form.on("Sales Order Item", {
    items_add: function(frm, cdt, cdn) {
        // Assign the parent cost center when new row is added
        if (frm.doc.cost_center) {
            frappe.model.set_value(cdt, cdn, "cost_center", frm.doc.cost_center);
        }
    }
});


frappe.ui.form.on('Sales Order Item', {
	refresh(frm) {
		// your code here
	}
})