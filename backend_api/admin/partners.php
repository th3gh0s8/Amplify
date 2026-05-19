<?php include 'header.php'; ?>

<?php
if (isset($_GET['authorize'])) {
    $id = (int)$_GET['authorize'];
    $conn->query("UPDATE partners SET status = 'authorized' WHERE ID = $id");
    header("Location: partners.php?msg=authorized");
    exit;
}

$sort = $_GET['sort'] ?? 'ID';
$order = $_GET['order'] ?? 'DESC';

// Fetch all column names for sorting validation and headers
$result_meta = $conn->query("SELECT * FROM partners LIMIT 1");
$fields = $result_meta->fetch_fields();
$allowed_cols = [];
foreach ($fields as $field) {
    $allowed_cols[] = $field->name;
}

if (!in_array($sort, $allowed_cols)) $sort = 'ID';
$next_order = ($order == 'ASC') ? 'DESC' : 'ASC';

$sql = "SELECT * FROM partners ORDER BY $sort $order";
$result = $conn->query($sql);
?>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h2>Partners Management</h2>
</div>

<?php if(isset($_GET['msg'])): ?>
    <div class="alert alert-success">Partner updated successfully!</div>
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
                                    $cls = ($val == 'authorized') ? 'bg-success' : (($val == 'pending') ? 'bg-warning text-dark' : 'bg-danger');
                                    echo "<span class='badge $cls'>" . strtoupper($val) . "</span>";
                                } elseif (strlen($val) > 50) {
                                    echo "<span title='" . htmlspecialchars($val) . "'>" . substr(htmlspecialchars($val), 0, 50) . "...</span>";
                                } else {
                                    echo htmlspecialchars($val);
                                }
                            ?>
                        </td>
                    <?php endforeach; ?>
                    <td class="text-nowrap">
                        <?php if(strtolower($row['status'] ?? '') == 'pending'): ?>
                            <a href="partners.php?authorize=<?php echo $row['ID']; ?>" class="btn btn-sm btn-success" onclick="return confirm('Authorize this partner?')">
                                <i class="bi bi-person-check"></i> Authorize
                            </a>
                        <?php endif; ?>
                        <a href="edit_partner.php?id=<?php echo $row['ID']; ?>" class="btn btn-sm btn-warning">
                            <i class="bi bi-pencil-square"></i> Edit
                        </a>
                    </td>
                </tr>
                <?php endwhile; ?>
            <?php else: ?>
                <tr><td colspan="<?php echo count($fields) + 1; ?>" class="text-center py-4 text-muted">No partners found</td></tr>
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

    // Sync width
    const syncWidth = () => {
        topContent.style.width = table.offsetWidth + 'px';
    };

    // Sync scroll
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
