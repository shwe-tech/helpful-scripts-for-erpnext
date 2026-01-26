// Invoice ရဲ့ Form မှာ Cost Center ကို ရွေးတာနဲ့ Item Table ထဲမှာရှိတဲ့ Cost Center တွေ အလိုလျောက်ရွေးချယ်စေပါတယ်။
// Default Function အရ Form မှာ Cost Center ကို အပြောင်းအလဲလုပ်ရင် Table ရဲ့ Entry တွေမှာ Effect မရှိတဲ့အတွက်ကြောင့်ဖြစ်ပါတယ်။

frappe.ui.form.on("Sales Invoice", {
    cost_center: function(frm) {
        if (!frm.doc.cost_center) return;

        // 1. Allocate Cost Center to Items table
        (frm.doc.items || []).forEach(function(row) {
            frappe.model.set_value(
                row.doctype,
                row.name,
                "cost_center",
                frm.doc.cost_center
            );
        });

        // 2. Allocate Cost Center to Taxes table
        (frm.doc.taxes || []).forEach(function(row) {
            frappe.model.set_value(
                row.doctype,
                row.name,
                "cost_center",
                frm.doc.cost_center
            );
        });

        frm.refresh_fields(["items", "taxes"]);
    }
});

// When a new Item row is added
frappe.ui.form.on("Sales Invoice Item", {
    items_add: function(frm, cdt, cdn) {
        if (frm.doc.cost_center) {
            frappe.model.set_value(
                cdt,
                cdn,
                "cost_center",
                frm.doc.cost_center
            );
        }
    }
});

// When a new Tax row is added
frappe.ui.form.on("Sales Taxes and Charges", {
    taxes_add: function(frm, cdt, cdn) {
        if (frm.doc.cost_center) {
            frappe.model.set_value(
                cdt,
                cdn,
                "cost_center",
                frm.doc.cost_center
            );
        }
    }
});
