<?php include 'header.php'; ?>

<?php
// Ensure tables exist
$conn->query("CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    partner_id INT DEFAULT 0,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_read TINYINT DEFAULT 0
)");

$conn->query("CREATE TABLE IF NOT EXISTS notification_reads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    notification_id INT NOT NULL,
    partner_id INT NOT NULL,
    read_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (notification_id, partner_id)
)");

if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['send_notification'])) {
    $target_type = $_POST['target'];
    $partner_id = 0;
    
    if ($target_type == 'partner') {
        $partner_id = (int)$_POST['partner_id'];
    } elseif ($target_type == 'customer') {
        $customer_id = (int)$_POST['customer_id'];
        $res = $conn->query("SELECT partnerTb FROM new_clients WHERE ID = $customer_id");
        if ($row = $res->fetch_assoc()) {
            $partner_id = (int)$row['partnerTb'];
        }
    }
    
    $title = $_POST['title'];
    $message = $_POST['message'];

    $stmt = $conn->prepare("INSERT INTO notifications (partner_id, title, message) VALUES (?, ?, ?)");
    $stmt->bind_param("iss", $partner_id, $title, $message);

    if ($stmt->execute()) {
        echo "<div class='alert alert-success'>Notification sent successfully!</div>";
    } else {
        echo "<div class='alert alert-danger'>Failed to send notification: " . $conn->error . "</div>";
    }
}

if (isset($_GET['delete'])) {
    $id = (int)$_GET['delete'];
    $conn->query("DELETE FROM notifications WHERE id = $id");
    header("Location: notifications.php?msg=deleted");
    exit;
}

$notifications = $conn->query("SELECT n.*, p.first_name, p.last_name 
                             FROM notifications n 
                             LEFT JOIN partners p ON n.partner_id = p.ID 
                             ORDER BY n.id DESC");
?>

<div class="row">
    <div class="col-md-4">
        <div class="card shadow-sm">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Send New Notification</h5>
            </div>
            <div class="card-body">
                <form method="POST">
                    <div class="mb-3">
                        <label class="form-label">Recipient</label>
                        <select name="target" id="targetSelect" class="form-control" required onchange="toggleSpecifics()">
                            <option value="all">All Partners</option>
                            <option value="partner">Specific Partner</option>
                            <option value="customer">Partner of Specific Customer</option>
                        </select>
                    </div>
                    <div id="partnerSelectDiv" class="mb-3" style="display:none;">
                        <label class="form-label">Select Partner</label>
                        <select name="partner_id" id="partnerSelect" class="form-control">
                            <?php
                            $partners = $conn->query("SELECT ID, first_name, last_name FROM partners ORDER BY first_name ASC");
                            while($p = $partners->fetch_assoc()) {
                                echo "<option value='{$p['ID']}'>{$p['first_name']} {$p['last_name']} (ID: {$p['ID']})</option>";
                            }
                            ?>
                        </select>
                    </div>
                    <div id="customerSelectDiv" class="mb-3" style="display:none;">
                        <label class="form-label">Select Customer</label>
                        <select name="customer_id" id="customerSelect" class="form-control">
                            <?php
                            $customers = $conn->query("SELECT c.ID, c.com_name, p.first_name, p.last_name, c.partnerTb 
                                                     FROM new_clients c 
                                                     LEFT JOIN partners p ON c.partnerTb = p.ID 
                                                     ORDER BY c.com_name ASC");
                            while($c = $customers->fetch_assoc()) {
                                $pname = $c['first_name'] ? "{$c['first_name']} {$c['last_name']}" : "Unknown Partner (ID: {$c['partnerTb']})";
                                echo "<option value='{$c['ID']}'>{$c['com_name']} (Partner: $pname)</option>";
                            }
                            ?>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Title</label>
                        <input type="text" name="title" class="form-control" placeholder="Notification Title" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Message</label>
                        <textarea name="message" class="form-control" rows="4" placeholder="Type your message here..." required></textarea>
                    </div>
                    <button type="submit" name="send_notification" class="btn btn-primary w-100">
                        <i class="bi bi-send"></i> Send Notification
                    </button>
                </form>
            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="card shadow-sm">
            <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Notification History</h5>
                <?php if(isset($_GET['msg'])): ?>
                    <span class="badge bg-success">Deleted Successfully</span>
                <?php endif; ?>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Date</th>
                                <th>Target</th>
                                <th>Title</th>
                                <th>Message</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if ($notifications->num_rows > 0): ?>
                                <?php while($n = $notifications->fetch_assoc()): ?>
                                <tr>
                                    <td class="small"><?php echo date('M d, H:i', strtotime($n['created_at'])); ?></td>
                                    <td>
                                        <?php if($n['partner_id'] == 0): ?>
                                            <span class="badge bg-info">ALL</span>
                                        <?php else: ?>
                                            <span class="badge bg-secondary"><?php echo $n['first_name'] . ' ' . $n['last_name']; ?></span>
                                        <?php endif; ?>
                                    </td>
                                    <td class="fw-bold"><?php echo htmlspecialchars($n['title']); ?></td>
                                    <td class="small"><?php echo nl2br(htmlspecialchars($n['message'])); ?></td>
                                    <td>
                                        <a href="notifications.php?delete=<?php echo $n['id']; ?>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this notification history?')">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                    </td>
                                </tr>
                                <?php endwhile; ?>
                            <?php else: ?>
                                <tr><td colspan="5" class="text-center py-4 text-muted">No notifications sent yet</td></tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<?php include 'footer.php'; ?>

<script>
function toggleSpecifics() {
    const target = document.getElementById('targetSelect').value;
    document.getElementById('partnerSelectDiv').style.display = (target === 'partner') ? 'block' : 'none';
    document.getElementById('customerSelectDiv').style.display = (target === 'customer') ? 'block' : 'none';
    
    // Re-initialize TomSelect with no limits when visible
    if (target === 'partner') {
        const el = document.getElementById('partnerSelect');
        if (el.tomselect) el.tomselect.destroy();
        new TomSelect(el, { create: false, maxOptions: null, sortField: { field: "text", order: "asc" } });
    }
    
    if (target === 'customer') {
        const el = document.getElementById('customerSelect');
        if (el.tomselect) el.tomselect.destroy();
        new TomSelect(el, { create: false, maxOptions: null, sortField: { field: "text", order: "asc" } });
    }
}
</script>
