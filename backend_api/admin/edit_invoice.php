<?php include 'header.php'; ?>

<?php
$id = (int)($_GET['id'] ?? 0);
$is_new = isset($_GET['new']);

// Fetch schema
$result_meta = $conn->query("SELECT * FROM invoices LIMIT 1");
$fields = $result_meta->fetch_fields();

// Reorder fields: move partner_tb before br_id
$reordered = [];
$p_idx = -1;
$b_idx = -1;
foreach($fields as $i => $f) {
    if($f->name == 'partner_tb') $p_idx = $i;
    if($f->name == 'br_id') $b_idx = $i;
}

if ($p_idx !== -1 && $b_idx !== -1) {
    $p_field = $fields[$p_idx];
    $temp_fields = array_values(array_filter($fields, fn($f) => $f->name !== 'partner_tb'));
    // Find new br_id index
    foreach($temp_fields as $i => $f) if($f->name == 'br_id') $b_idx = $i;
    array_splice($temp_fields, $b_idx, 0, [$p_field]);
    $fields = $temp_fields;
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = [];
    foreach ($fields as $field) {
        if ($field->name == 'ID') continue;
        $data[$field->name] = $_POST[$field->name] ?? null;
    }
    
    if ($is_new) {
        $cols = implode('`, `', array_keys($data));
        $placeholders = implode(', ', array_fill(0, count($data), '?'));
        $sql = "INSERT INTO invoices (`$cols`) VALUES ($placeholders)";
        $stmt = $conn->prepare($sql);
        $types = "";
        foreach($data as $key => $val) {
            $f = array_filter($fields, fn($field) => $field->name == $key);
            $f = reset($f);
            if (in_array($f->type, [3, 8, 9])) $types .= "i";
            elseif (in_array($f->type, [4, 5])) $types .= "d";
            else $types .= "s";
        }
        $stmt->bind_param($types, ...array_values($data));
    } else {
        $updates = [];
        $types = "";
        $values = [];
        foreach ($data as $key => $val) {
            $updates[] = "`$key` = ?";
            $values[] = $val;
            $f = array_filter($fields, fn($field) => $field->name == $key);
            $f = reset($f);
            if (in_array($f->type, [3, 8, 9])) $types .= "i";
            elseif (in_array($f->type, [4, 5])) $types .= "d";
            else $types .= "s";
        }
        $sql = "UPDATE invoices SET " . implode(', ', $updates) . " WHERE ID = ?";
        $stmt = $conn->prepare($sql);
        $types .= "i";
        $values[] = $id;
        $stmt->bind_param($types, ...$values);
    }
    
    if ($stmt->execute()) {
        $msg = $is_new ? "created" : "updated";
        header("Location: invoices.php?msg=$msg");
        exit;
    } else {
        echo "<div class='alert alert-danger'>Operation failed: " . $conn->error . "</div>";
    }
}

$invoice = $is_new ? [] : $conn->query("SELECT * FROM invoices WHERE ID = $id")->fetch_assoc();
if (!$is_new && !$invoice) { echo "Invoice not found"; include 'footer.php'; exit; }
?>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h2><?php echo $is_new ? 'Create New Invoice' : 'Edit Invoice: #' . $id; ?></h2>
    <a href="invoices.php" class="btn btn-secondary">Back to List</a>
</div>

<form method="POST" class="card shadow-sm">
    <div class="card-body">
        <div class="row">
            <?php foreach ($fields as $field): ?>
                <?php if ($field->name == 'ID') continue; ?>
                <div class="col-md-4 mb-3">
                    <label class="form-label small fw-bold text-uppercase"><?php echo str_replace('_', ' ', $field->name); ?></label>
                    <?php
                        $val = $invoice[$field->name] ?? '';
                        $name = $field->name;
                        
                        if ($field->name == 'cus_tb') {
                            $customers = $conn->query("SELECT ID, com_name, admin_name, total_cost, partnerTb FROM new_clients ORDER BY com_name ASC");
                            $cus_data = [];
                            echo "<select name='$name' id='cus_tb_select' class='form-control' required>";
                            echo "<option value=''>-- Select Customer --</option>";
                            while($c = $customers->fetch_assoc()) {
                                $sel = ($val == $c['ID']) ? 'selected' : '';
                                echo "<option value='{$c['ID']}' $sel data-partner='{$c['partnerTb']}'>{$c['com_name']} (ID: {$c['ID']})</option>";
                                $cus_data[$c['ID']] = [
                                    'name' => $c['admin_name'],
                                    'value' => $c['total_cost'],
                                    'partner' => $c['partnerTb']
                                ];
                            }
                            echo "</select>";
                            echo "<script>const customerData = " . json_encode($cus_data) . ";</script>";
                        } elseif ($field->name == 'cus_name') {
                            echo "<input type='text' name='$name' id='cus_name_input' class='form-control' value='" . htmlspecialchars($val) . "'>";
                        } elseif ($field->name == 'partner_tb') {
                            $partners = $conn->query("SELECT ID, first_name, last_name FROM partners ORDER BY first_name ASC");
                            echo "<select name='$name' id='partner_tb_select' class='form-control' required>";
                            echo "<option value=''>-- Select Partner --</option>";
                            while($p = $partners->fetch_assoc()) {
                                $sel = ($val == $p['ID']) ? 'selected' : '';
                                echo "<option value='{$p['ID']}' $sel>{$p['first_name']} {$p['last_name']} (ID: {$p['ID']})</option>";
                            }
                            echo "</select>";
                        } elseif ($field->name == 'date') {
                            $val = $val ?: date('Y-m-d');
                            echo "<input type='date' name='$name' class='form-control' value='$val' required>";
                        } elseif ($field->name == 'time') {
                            $val = $val ?: date('H:i:s');
                            echo "<input type='time' step='1' name='$name' class='form-control' value='$val' required>";
                        } else {
                            $type = in_array($field->type, [3, 8, 9, 4, 5]) ? 'number' : 'text';
                            $id_attr = ($field->name == 'value') ? "id='value_input'" : "";
                            echo "<input type='$type' name='$name' $id_attr class='form-control' value='" . htmlspecialchars($val) . "'>";
                        }
                    ?>
                </div>
            <?php endforeach; ?>
        </div>
    </div>
    <div class="card-footer bg-light text-end">
        <button type="submit" class="btn btn-primary px-5"><?php echo $is_new ? 'Create Invoice' : 'Save Changes'; ?></button>
    </div>
</form>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const partnerEl = document.getElementById('partner_tb_select');
    const customerEl = document.getElementById('cus_tb_select');
    const nameInput = document.getElementById('cus_name_input');
    const valueInput = document.getElementById('value_input');

    if (!partnerEl || !customerEl) return;

    // Initialize Tom Select
    const partnerTS = new TomSelect(partnerEl, { create: false });
    
    // Map initial options correctly
    const initialOptions = Array.from(customerEl.options).map(opt => ({
        id: opt.value,
        text: opt.text,
        partner: opt.getAttribute('data-partner') || ""
    }));

    const customerTS = new TomSelect(customerEl, {
        create: false,
        valueField: 'id',
        labelField: 'text',
        searchField: 'text',
        options: initialOptions
    });

    // Store the full set of options for filtering
    const fullCustomerOptions = JSON.parse(JSON.stringify(customerTS.options));

    function filterCustomers() {
        const partnerId = partnerTS.getValue();
        const currentVal = customerTS.getValue();

        // Toggle availability based on partner selection
        if (partnerId === "") {
            customerTS.disable();
        } else {
            customerTS.enable();
        }

        // Clear current options and re-add filtered ones
        customerTS.clearOptions();

        const filtered = Object.values(fullCustomerOptions).filter(opt => {
            if (opt.id === "") return true; // Keep placeholder
            
            // If no partner selected, normally we'd show none or all, 
            // but user wants it unavailable. We keep all for when it IS enabled.
            if (partnerId === "") return true;
            
            // If partner selected, show if partner matches OR if it's the currently selected customer
            return String(opt.partner) === String(partnerId) || opt.id === currentVal;
        });

        customerTS.addOptions(filtered);
        customerTS.refreshOptions(false);
    }

    partnerTS.on('change', function() {
        customerTS.clear();
        filterCustomers();
    });
    
    customerTS.on('change', function(selectedId) {
        const data = customerData[selectedId];
        if (data) {
            if (nameInput) nameInput.value = data.name;
            if (valueInput) valueInput.value = data.value;
        } else {
            if (nameInput) nameInput.value = '';
            if (valueInput) valueInput.value = '';
        }
    });

    // Initial filter
    filterCustomers();
});
</script>

<?php include 'footer.php'; ?>
