<?php ob_start(); include 'header.php'; ?>

<?php
$sort = $_GET['sort'] ?? 'ID';
$order = strtoupper($_GET['order'] ?? 'DESC');

// SECURE: Strictly validate $order to prevent SQL Injection
if ($order !== 'ASC' && $order !== 'DESC') {
    $order = 'DESC';
}

// Fetch all column names for sorting validation and headers
$result_meta = $conn->query("SELECT * FROM invoices LIMIT 1");
$fields = $result_meta->fetch_fields();
$allowed_cols = [];
foreach ($fields as $field) {
    $allowed_cols[] = $field->name;
}

if (!in_array($sort, $allowed_cols)) $sort = 'ID';
$next_order = ($order == 'ASC') ? 'DESC' : 'ASC';

$sql = "SELECT * FROM invoices ORDER BY $sort $order";
$result = $conn->query($sql);

if (isset($_GET['delete'])) {
    $id = $_GET['delete'];

    // SECURE: Use a prepared statement for the deletion
    $stmt = $conn->prepare("DELETE FROM invoices WHERE ID = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $stmt->close();

    header("Location: invoices.php?msg=deleted");
    exit;
}
?>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h2>Invoices Management</h2>
    <a href="edit_invoice.php?new=1" class="btn btn-success">
        <i class="bi bi-plus-circle"></i> Create New Invoice
    </a>
</div>

<?php if(isset($_GET['msg'])): ?>
    <div class="alert alert-success">Invoice <?php echo $_GET['msg']; ?> successfully!</div>
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
                                $label = str_replace(['_', 'Tb', 'id'], [' ', ' Table', ' ID'], $field->name);
                                echo ucwords($label);
                            ?>
                            <?php if ($sort == $field->name): ?>
                                <i class="bi bi-caret-<?php echo ($order == 'ASC') ? 'up' : 'down'; ?>-fill"></i>
                            <?php endif; ?>
                        </a>
                    </th>
                <?php endforeach; ?>
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
                                if (in_array($field->name, ['value', 'com_amount', 'paid', 'balance'])) {
                                    echo "LKR " . number_format((float)$val, 2);
                                } else {
                                    echo htmlspecialchars($val);
                                }
                            ?>
                        </td>
                    <?php endforeach; ?>
                    <td class="text-nowrap">
                        <a href="edit_invoice.php?id=<?php echo $row['ID']; ?>" class="btn btn-sm btn-warning">
                            <i class="bi bi-pencil-square"></i> Edit
                        </a>
                        <a href="invoices.php?delete=<?php echo $row['ID']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this invoice?')">
                            <i class="bi bi-trash"></i>
                        </a>
                    </td>
                </tr>
                <?php endwhile; ?>
            <?php else: ?>
                <tr><td colspan="<?php echo count($fields) + 1; ?>" class="text-center py-4 text-muted">No invoices found</td></tr>
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
    const syncWidth = () => { topContent.style.width = table.offsetWidth + 'px'; };
    topScroll.onscroll = () => { tableScroll.scrollLeft = topScroll.scrollLeft; };
    tableScroll.onscroll = () => { topScroll.scrollLeft = tableScroll.scrollLeft; };
    window.addEventListener('resize', syncWidth);
    syncWidth();
});
</script>

<?php include 'footer.php'; ?>
