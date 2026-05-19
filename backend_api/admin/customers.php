<?php include 'header.php'; ?>

<?php
if (isset($_GET['activate'])) {
    $id = (int)$_GET['activate'];
    $conn->query("UPDATE new_clients SET status = 'active' WHERE ID = $id");
    header("Location: customers.php?msg=activated");
    exit;
}

$sort = $_GET['sort'] ?? 'ID';
$order = $_GET['order'] ?? 'DESC';

// Fetch all column names for sorting validation and headers
$result_meta = $conn->query("SELECT * FROM new_clients LIMIT 1");
$fields = $result_meta->fetch_fields();
$allowed_cols = [];
foreach ($fields as $field) {
    $allowed_cols[] = $field->name;
}

// Add virtual columns for joined data
$allowed_cols[] = 'partner_first';
$allowed_cols[] = 'partner_last';

if (!in_array($sort, $allowed_cols)) $sort = 'ID';
$next_order = ($order == 'ASC') ? 'DESC' : 'ASC';

$sql = "SELECT c.*, p.first_name as partner_first, p.last_name as partner_last 
        FROM new_clients c 
        LEFT JOIN partners p ON c.partnerTb = p.ID 
        ORDER BY $sort $order";
$result = $conn->query($sql);
?>

<h2>Customers Management</h2>
<?php if(isset($_GET['msg'])): ?>
    <div class="alert alert-success">Customer activated successfully!</div>
<?php endif; ?>

<!-- Top Scroller -->
<div id="top-scroll-container" style="overflow-x: auto; overflow-y: hidden; height: 20px; margin-bottom: 2px;">
    <div id="top-scroll-content" style="height: 1px;"></div>
</div>

<div class="table-responsive shadow-sm" id="table-scroll-container">
    <table class="table table-striped table-hover table-bordered mb-0" id="data-table">
        <thead class="table-dark">
            <tr>
                <?php foreach ($fields as $field): ?>
                    <th class="text-nowrap">
                        <a href="?sort=<?php echo $field->name; ?>&order=<?php echo $next_order; ?>" class="text-white text-decoration-none">
                            <?php 
                                $label = str_replace('_', ' ', $field->name);
                                echo ucwords($label); 
                            ?>
                            <?php if ($sort == $field->name): ?>
                                <i class="bi bi-caret-<?php echo ($order == 'ASC') ? 'up' : 'down'; ?>-fill"></i>
                            <?php endif; ?>
                        </a>
                    </th>
                <?php endforeach; ?>
                <th class="text-nowrap">Partner</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php if ($result->num_rows > 0): ?>
                <?php while($row = $result->fetch_assoc()): ?>
                <tr>
                    <?php foreach ($fields as $field): ?>
                        <td>
                            <?php 
                                $val = $row[$field->name];
                                if ($field->name == 'status') {
                                    $cls = ($val == 'active' || $val == 'approved') ? 'bg-success' : 'bg-warning text-dark';
                                    echo "<span class='badge $cls'>" . strtoupper($val) . "</span>";
                                } elseif (strlen($val) > 50) {
                                    echo "<span title='" . htmlspecialchars($val) . "'>" . substr(htmlspecialchars($val), 0, 50) . "...</span>";
                                } else {
                                    echo htmlspecialchars($val);
                                }
                            ?>
                        </td>
                    <?php endforeach; ?>
                    <td class="text-nowrap small"><?php echo $row['partner_first'] . ' ' . $row['partner_last']; ?></td>
                    <td class="text-nowrap">
                        <?php if(strtolower($row['status'] ?? '') == 'pending'): ?>
                            <a href="customers.php?activate=<?php echo $row['ID']; ?>" class="btn btn-sm btn-success" onclick="return confirm('Activate this customer?')">
                                <i class="bi bi-check-circle"></i> Activate
                            </a>
                        <?php endif; ?>
                        <a href="edit_customer.php?id=<?php echo $row['ID']; ?>" class="btn btn-sm btn-warning">
                            <i class="bi bi-pencil-square"></i> Edit
                        </a>
                    </td>
                </tr>
                <?php endwhile; ?>
            <?php else: ?>
                <tr><td colspan="<?php echo count($fields) + 2; ?>" class="text-center py-4 text-muted">No customers found</td></tr>
            <?php endif; ?>
        </tbody>
    </table>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const topScroll = document.getElementById('top-scroll-container');
    const topContent = document.getElementById('top-scroll-content');
    const tableScroll = document.getElementById('table-scroll-container');
    const table = document.getElementById('data-table');

    const syncWidth = () => {
        topContent.style.width = table.offsetWidth + 'px';
    };

    topScroll.onscroll = () => {
        tableScroll.scrollLeft = topScroll.scrollLeft;
    };
    tableScroll.onscroll = () => {
        topScroll.scrollLeft = tableScroll.scrollLeft;
    };

    window.addEventListener('resize', syncWidth);
    syncWidth();
});
</script>

<?php include 'footer.php'; ?>
