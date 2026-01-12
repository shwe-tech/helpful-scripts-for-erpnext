# Sales Invoice မှာ Discount နှစ်ဆင့် စမ်းထားခြင်းဖြစ်တယ်။ အလုပ်မလုပ် မသိနိုင်ပါ။ (အသုံးမဝင်ပါက နောက်ပိုင်း ဖျက်ပါမယ်။)
# Script Type: DocType Event
# DocType Event: Before Submit

if doc.stock_entry_type == "Repack":
    total_raw_value = 0
    total_finished_qty = 0
    items_to_calculate = []
    assigned_value = 0

    # Step 1: Analyze items
    for item in doc.items:
        # Check if it is a target item (Finished or Scrap)
        if item.is_finished_item or item.is_scrap_item:
            # Check Item Master for pre-defined Valuation Rate
            pre_defined_rate = frappe.db.get_value("Item", item.item_code, "valuation_rate")
            
            if pre_defined_rate and frappe.utils.flt(pre_defined_rate) > 0:
                # 1. Use the pre-defined rate from Item Master
                item.basic_rate = frappe.utils.flt(pre_defined_rate)
                item.set_basic_rate_manually = 1
                item.basic_amount = item.basic_rate * frappe.utils.flt(item.qty)
                item.amount = item.basic_amount
                # Keep track of value already "consumed" by fixed-rate items
                assigned_value += item.basic_amount
            else:
                # 2. No pre-defined rate, add to list for equal distribution
                items_to_calculate.append(item)
                total_finished_qty += frappe.utils.flt(item.qty)
        
        elif item.s_warehouse and not item.t_warehouse:
            # Raw Materials (Source items) providing the value
            # Note: valuation_rate is usually populated on save/validate by ERPNext
            total_raw_value += frappe.utils.flt(item.valuation_rate) * frappe.utils.flt(item.qty)

    # Step 2: Distribute remaining value to items without pre-defined rates
    remaining_value = total_raw_value - assigned_value
    
    if items_to_calculate and remaining_value > 0 and total_finished_qty > 0:
        calculated_rate = remaining_value / total_finished_qty
        
        for item in items_to_calculate:
            item.basic_rate = calculated_rate
            item.set_basic_rate_manually = 1
            item.basic_amount = calculated_rate * frappe.utils.flt(item.qty)
            item.amount = item.basic_amount

    # Sync header totals
    doc.total_incoming_value = total_raw_value