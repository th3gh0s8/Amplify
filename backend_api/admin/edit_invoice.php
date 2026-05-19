<?php include 'header.php'; ?>

<?php
$id = (int)($_GET['id'] ?? 0);
$is_new = isset($_GET['new']);

// Fetch schema
$result_meta = $conn->query("SELECT * FROM invoices LIMIT 1");
$fields = $result_meta->fetch_fields();

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
    const partnerSelect = document.getElementById('partner_tb_select');
    const customerSelect = document.getElementById('cus_tb_select');
    const nameInput = document.getElementById('cus_name_input');
    const valueInput = document.getElementById('value_input');
    
    function filterCustomers() {
        const partnerId = partnerSelect.value;
        const options = customerSelect.options;
        let visibleCount = 0;
        
        for (let i = 0; i < options.length; i++) {
            const opt = options[i];
            if (opt.value === "") {
                opt.style.display = "";
                continue;
            }
            
            if (partnerId === "" || opt.getAttribute('data-partner') === partnerId) {
                opt.style.display = "";
                visibleCount++;
            } else {
                opt.style.display = "none";
                if (opt.selected) {
                    customerSelect.value = "";
                    if (nameInput) nameInput.value = "";
                    if (valueInput) valueInput.value = "";
                }
            }
        }
    }

    if (partnerSelect && customerSelect) {
        partnerSelect.addEventListener('change', filterCustomers);
        // Initial filter on load
        filterCustomers();
    }
    
    if (customerSelect) {
        customerSelect.addEventListener('change', function() {
            const selectedId = this.value;
            const data = customerData[selectedId];
            if (data) {
                if (nameInput) nameInput.value = data.name;
                if (valueInput) valueInput.value = data.value;
            } else {
                if (nameInput) nameInput.value = '';
                if (valueInput) valueInput.value = '';
            }
        });
    }
});
</script>

<?php include 'footer.php'; ?>
