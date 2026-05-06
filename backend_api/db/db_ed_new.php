<?php
session_start();

if (isset($_GET['code']) && $_GET['code'] === '2000') {
    $_SESSION['authenticated'] = true;
}

if (!isset($_SESSION['authenticated']) || $_SESSION['authenticated'] !== true) {
    http_response_code(403);
    die('Page Not Found.');
}

include('db_config.php');

// $conn = $mysqli;

// if (!isset($conn) || $conn->connect_error) {
//     $host = 'localhost'; $user = 'root'; $pass = ''; 
//     $conn = new mysqli($host, $user, $pass);
//     if ($conn->connect_error) die("Database connection failed: " . $conn->connect_error);
// }

// --- NEW HANDLERS ---
$msg = ''; 
$msg_type = '';

// 1. Create/Drop Database
if (isset($_POST['create_db'])) {
    $new_db = $conn->real_escape_string($_POST['db_name']);
    if ($conn->query("CREATE DATABASE `$new_db`")) {
        $msg = "Database `$new_db` created successfully."; $msg_type = "success";
    } else { $msg = "Error: " . $conn->error; $msg_type = "danger"; }
}

if (isset($_GET['action']) && $_GET['action'] === 'drop_db' && isset($_GET['db'])) {
    $target_db = $conn->real_escape_string($_GET['db']);
    if ($conn->query("DROP DATABASE `$target_db`")) {
        header("Location: db_ed_new.php?msg=Database dropped&type=success"); exit;
    } else { $msg = "Error: " . $conn->error; $msg_type = "danger"; }
}

// 2. Drop/Truncate Table
if (isset($_GET['action']) && isset($_GET['db']) && isset($_GET['table'])) {
    $conn->select_db($_GET['db']);
    $target_tbl = $conn->real_escape_string($_GET['table']);
    if ($_GET['action'] === 'drop_table') {
        if ($conn->query("DROP TABLE `$target_tbl`")) {
            header("Location: ?db=".$_GET['db']."&msg=Table dropped&type=success"); exit;
        } else { $msg = "Error: " . $conn->error; $msg_type = "danger"; }
    }
    if ($_GET['action'] === 'truncate_table') {
        if ($conn->query("TRUNCATE TABLE `$target_tbl`")) {
            header("Location: ?db=".$_GET['db']."&table=".$target_tbl."&msg=Table truncated&type=success"); exit;
        } else { $msg = "Error: " . $conn->error; $msg_type = "danger"; }
    }
}

// 3. Delete Row
if (isset($_POST['delete_row'])) {
    $conn->select_db($_POST['db']);
    $tbl = $conn->real_escape_string($_POST['table']);
    $pk_col = $_POST['pk_col'];
    $pk_val = $conn->real_escape_string($_POST['pk_val']);
    if ($conn->query("DELETE FROM `$tbl` WHERE `$pk_col` = '$pk_val'")) {
        $msg = "Row deleted successfully."; $msg_type = "success";
    } else { $msg = "Error: " . $conn->error; $msg_type = "danger"; }
}

// 4. Update Row
if (isset($_POST['update_row_submit'])) {
    $conn->select_db($_POST['target_db']);
    $tbl = $conn->real_escape_string($_POST['target_table']);
    $pk_col = $_POST['pk_col'];
    $pk_val = $conn->real_escape_string($_POST['pk_val']);
    
    $sets = [];
    foreach ($_POST['upd_data'] as $col => $val) {
        $sets[] = "`" . $conn->real_escape_string($col) . "` = '" . $conn->real_escape_string($val) . "'";
    }
    $sql_upd = "UPDATE `$tbl` SET " . implode(', ', $sets) . " WHERE `$pk_col` = '$pk_val'";
    if ($conn->query($sql_upd)) {
        $msg = "Row updated successfully."; $msg_type = "success";
    } else { $msg = "Error: " . $conn->error; $msg_type = "danger"; }
}

// 5. Import SQL
if (isset($_POST['import_sql'])) {
    if (isset($_FILES['sql_file']) && $_FILES['sql_file']['error'] == 0) {
        if ($_POST['target_db']) $conn->select_db($_POST['target_db']);
        $sql = file_get_contents($_FILES['sql_file']['tmp_name']);
        if ($conn->multi_query($sql)) {
            do { if ($res = $conn->store_result()) { $res->free(); } } while ($conn->more_results() && $conn->next_result());
            $msg = "SQL imported successfully."; $msg_type = "success";
        } else { $msg = "Import Error: " . $conn->error; $msg_type = "danger"; }
    }
}

// 6. Export SQL (needs to be before any HTML)
if (isset($_GET['action']) && $_GET['action'] === 'export' && isset($_GET['db'])) {
    $target_db = $_GET['db'];
    $conn->select_db($target_db);
    $filename = $target_db . (isset($_GET['table']) ? "_" . $_GET['table'] : "") . "_" . date('Y-m-d') . ".sql";
    
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    
    $tables = isset($_GET['table']) ? [$_GET['table']] : [];
    if (empty($tables)) {
        $res = $conn->query("SHOW TABLES");
        while($row = $res->fetch_row()) $tables[] = $row[0];
    }
    
    foreach ($tables as $tbl) {
        $res = $conn->query("SHOW CREATE TABLE `$tbl`");
        $row = $res->fetch_row();
        echo "\n\n" . $row[1] . ";\n\n";
        
        $res = $conn->query("SELECT * FROM `$tbl`");
        while ($row = $res->fetch_assoc()) {
            $vals = array_map([$conn, 'real_escape_string'], array_values($row));
            echo "INSERT INTO `$tbl` VALUES ('" . implode("', '", $vals) . "');\n";
        }
    }
    exit;
}

if (isset($_GET['msg'])) { $msg = $_GET['msg']; $msg_type = $_GET['type'] ?? 'info'; }

$selected_db = isset($_GET['db']) ? $_GET['db'] : '';
$selected_table = isset($_GET['table']) ? $_GET['table'] : '';

$global_search = isset($_GET['search']) ? $_GET['search'] : '';

$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 25;
$offset = ($page - 1) * $limit;

$is_custom_query = false;
$sql_query_input = "";

if (isset($_POST['insert_data_submit'])) {
    $target_db = $_POST['target_db'];
    $target_table = $_POST['target_table'];
    $conn->select_db($target_db);
    
    $insert_rows = $_POST['ins_data'];
    $success_count = 0;
    $error_count = 0;
    $last_error = '';

    foreach ($insert_rows as $row_data) {
        $cols = [];
        $vals = [];
        foreach ($row_data as $col => $val) {
            $cols[] = "`" . $conn->real_escape_string($col) . "`";
            $vals[] = "'" . $conn->real_escape_string($val) . "'";
        }
        
        $sql_ins = "INSERT INTO `$target_table` (" . implode(', ', $cols) . ") VALUES (" . implode(', ', $vals) . ")";
        
        if ($conn->query($sql_ins)) {
            $success_count++;
        } else {
            $error_count++;
            $last_error = $conn->error;
        }
    }

    if ($error_count == 0) {
        $msg = "Successfully inserted $success_count row(s).";
        $msg_type = "success";
    } else {
        $msg = "Inserted $success_count rows. Failed $error_count rows. Error: $last_error";
        $msg_type = "warning";
    }
}

if (isset($_POST['run_sql'])) {
    $sql_query_input = $_POST['sql_query'];
    $target = $_POST['target_db'] ?: $selected_db;
    
    if ($target) {
        $conn->select_db($target);
        $is_custom_query = true;
        

        $trim_sql = trim(strtoupper($sql_query_input));
        if (strpos($trim_sql, 'SELECT') === 0 || strpos($trim_sql, 'SHOW') === 0 || strpos($trim_sql, 'DESCRIBE') === 0 || strpos($trim_sql, 'EXPLAIN') === 0) {
        } else {
            try {
                if ($conn->multi_query($sql_query_input)) {
                    $msg = "Query executed successfully!"; $msg_type = "success";
                    do { if ($res = $conn->store_result()) { $res->free(); } } while ($conn->more_results() && $conn->next_result());
                }
            } catch (Exception $e) { $msg = $e->getMessage(); $msg_type = "danger"; }
            $is_custom_query = false; 
        }
    } else { $msg = "Select a database first."; $msg_type = "warning"; }
}

$db_list = [];
$res = $conn->query("SHOW DATABASES");
if($res) while ($row = $res->fetch_row()) { 
    if (!in_array($row[0], ['information_schema', 'mysql', 'performance_schema', 'sys'])) {
        $db_name = $row[0];
        $tbl_count = 0;
        $db_size = 0;
        
        $t_res = $conn->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$db_name'");
        if ($t_res) $tbl_count = $t_res->fetch_row()[0];
        
        $s_res = $conn->query("SELECT SUM(data_length + index_length) FROM information_schema.tables WHERE table_schema = '$db_name'");
        if ($s_res) $db_size = $s_res->fetch_row()[0];
        
        $db_list[] = [
            'name' => $db_name,
            'tables' => $tbl_count,
            'size' => round($db_size / 1024 / 1024, 2) . ' MB'
        ];
    }
}

$server_stats = [];
if (!$selected_db) {
    $server_stats['version'] = $conn->server_info;
    $res = $conn->query("SHOW STATUS LIKE 'Uptime'");
    $server_stats['uptime'] = ($res) ? $res->fetch_assoc()['Value'] : 0;
    $res = $conn->query("SHOW STATUS LIKE 'Threads_connected'");
    $server_stats['threads'] = ($res) ? $res->fetch_assoc()['Value'] : 0;
}

$table_list = [];
$db_schema_json = "{}";

if ($selected_db) {
    $conn->select_db($selected_db);
    $res = $conn->query("SHOW TABLES");
    $schema_map = [];
    
    if($res) {
        while ($row = $res->fetch_row()) {
            $tbl = $row[0];
            $table_list[] = $tbl;
            $cols_res = $conn->query("DESCRIBE `$tbl`");
            $t_cols = [];
            if($cols_res) {
                while($c_row = $cols_res->fetch_assoc()) {
                    $t_cols[] = $c_row['Field'];
                }
            }
            $schema_map[$tbl] = $t_cols;
        }
    }
    $db_schema_json = json_encode($schema_map);
}

$columns = [];
$rows = [];
$total_rows = 0;
$total_pages = 1;
$active_filters_list = [];
$active_sort = [];
$structure = [];
$create_table_sql = "";
$primary_key = "";

if ($selected_db) {
    $conn->select_db($selected_db);

    if ($is_custom_query && $sql_query_input) {
        try {
            $res = $conn->query($sql_query_input);
            if ($res) {
                $finfo = $res->fetch_fields();
                foreach ($finfo as $val) $columns[] = ['Field' => $val->name, 'Type' => $val->type];
                while ($row = $res->fetch_assoc()) $rows[] = $row;
                $total_rows = count($rows);
                $msg = "Custom Query Results: " . $total_rows . " rows.";
            }
        } catch (Exception $e) { $msg = $e->getMessage(); $msg_type = "danger"; }
    } 
    elseif ($selected_table) {

        $res = $conn->query("DESCRIBE `$selected_table`");
        while ($row = $res->fetch_assoc()) { 
            $structure[] = $row; 
            if ($row['Key'] == 'PRI') $primary_key = $row['Field'];
        }

        $res_cr = $conn->query("SHOW CREATE TABLE `$selected_table`");
        if($res_cr) {
            $row_cr = $res_cr->fetch_row();
            $create_table_sql = isset($row_cr[1]) ? $row_cr[1] : '';
        }

        $where_clauses = [];
        $order_sql = "";
        
        if ($global_search && !empty($structure)) {
            $search_term = $conn->real_escape_string($global_search);
            $g_clauses = [];
            foreach ($structure as $col) {
                $g_clauses[] = "`" . $col['Field'] . "` LIKE '%$search_term%'";
            }
            if(!empty($g_clauses)) {
                $where_clauses[] = "(" . implode(" OR ", $g_clauses) . ")";
            }
        }

        if (isset($_GET['filter_col']) && is_array($_GET['filter_col'])) {
            $f_cols = $_GET['filter_col'];
            $f_ops = isset($_GET['filter_op']) ? $_GET['filter_op'] : [];
            $f_vals = isset($_GET['filter_val']) ? $_GET['filter_val'] : [];
            
            for ($i = 0; $i < count($f_cols); $i++) {
                $f_col = isset($f_cols[$i]) ? $conn->real_escape_string($f_cols[$i]) : '';
                $f_op = isset($f_ops[$i]) ? $f_ops[$i] : '';
                $f_val = isset($f_vals[$i]) ? $f_vals[$i] : '';

                if ($f_col === '') continue;

                $clause = "";
                $esc_val = $conn->real_escape_string($f_val);

                switch ($f_op) {
                    case 'EQ': $clause = "`$f_col` = '$esc_val'"; break;
                    case 'NEQ': $clause = "`$f_col` != '$esc_val'"; break;
                    case 'GT': $clause = "`$f_col` > '$esc_val'"; break;
                    case 'GTE': $clause = "`$f_col` >= '$esc_val'"; break;
                    case 'LT': $clause = "`$f_col` < '$esc_val'"; break;
                    case 'LTE': $clause = "`$f_col` <= '$esc_val'"; break;
                    case 'LIKE': $clause = "`$f_col` LIKE '%$esc_val%'"; break;
                    case 'NOT_LIKE': $clause = "`$f_col` NOT LIKE '%$esc_val%'"; break;
                    case 'IS_NULL': $clause = "`$f_col` IS NULL"; break;
                    case 'NOT_NULL': $clause = "`$f_col` IS NOT NULL"; break;
                    case 'IN':
                    case 'NOT_IN':
                        $parts = explode(',', $f_val);
                        $safe_parts = [];
                        foreach($parts as $p) {
                            $p_trim = trim($p);
                            if($p_trim !== '') {
                                $safe_parts[] = "'" . $conn->real_escape_string($p_trim) . "'";
                            }
                        }
                        if(!empty($safe_parts)) {
                            $in_list = implode(',', $safe_parts);
                            $op = ($f_op == 'IN') ? 'IN' : 'NOT IN';
                            $clause = "`$f_col` $op ($in_list)";
                        }
                        break;
                }
                
                if ($clause) {
                    $where_clauses[] = $clause;
                }
                
                $active_filters_list[] = ['col' => $f_col, 'op' => $f_op, 'val' => $f_val];
            }
        }

        $where_sql = "";
        if(!empty($where_clauses)) {
            $where_sql = "WHERE " . implode(" AND ", $where_clauses);
        }

        if (isset($_GET['sort_col']) && $_GET['sort_col'] != '') {
            $s_col = $conn->real_escape_string($_GET['sort_col']);
            $s_dir = ($_GET['sort_dir'] == 'DESC') ? 'DESC' : 'ASC';
            $order_sql = "ORDER BY `$s_col` $s_dir";
            $active_sort['col'] = $s_col; 
            $active_sort['dir'] = $s_dir;
        }

        $c_res = $conn->query("SELECT COUNT(*) as total FROM `$selected_table` $where_sql");
        if($c_res) {
            $c_row = $c_res->fetch_assoc();
            $total_rows = $c_row['total'];
            $total_pages = ceil($total_rows / $limit);
        }

        $final_sql = "SELECT * FROM `$selected_table` $where_sql $order_sql LIMIT $offset, $limit";
        if(!$is_custom_query) $sql_query_input = $final_sql; 
        
        $res = $conn->query($final_sql);
        if($res) {
            foreach ($structure as $st) $columns[] = $st;
            while ($row = $res->fetch_assoc()) $rows[] = $row;
        }
    }
}

function build_url($page, $limit, $search) {
    global $selected_db, $selected_table;
    $url = "?db=$selected_db&table=$selected_table&page=$page&limit=$limit";
    if($search) $url .= "&search=" . urlencode($search);
    return $url;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DB Master Enhanced</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root { --sidebar-w: 260px; --bg-dark: #2c3e50; }
        body { background: #f4f6f9; height: 100vh; overflow: hidden; display: flex; font-family: 'Segoe UI', system-ui, sans-serif; }
        
        .sidebar { width: var(--sidebar-w); background: var(--bg-dark); color: #ecf0f1; display: flex; flex-direction: column; flex-shrink: 0; transition: margin 0.3s; }
        .sidebar-header { padding: 15px; background: #1a252f; border-bottom: 1px solid #34495e; }
        .db-list { flex-grow: 1; overflow-y: auto; }
        .db-link { display: block; padding: 10px 15px; color: #bdc3c7; text-decoration: none; border-bottom: 1px solid #34495e; transition: 0.2s; }
        .db-link:hover, .db-link.active { background: #34495e; color: #fff; border-left: 4px solid #3498db; }
        
        .sidebar.collapsed { margin-left: calc(var(--sidebar-w) * -1); }

        .table-container { background: #233342; padding: 10px 0; }
        .table-link { padding: 5px 15px 5px 35px; font-size: 0.9em; color: #95a5a6; display: block; text-decoration: none; word-break: break-all;}
        .table-link:hover, .table-link.active { color: #fff; background: rgba(255,255,255,0.05); }
        .table-link.active { font-weight: bold; color: #fff; border-left: 2px solid #2ecc71; }

        .main { flex-grow: 1; display: flex; flex-direction: column; height: 100%; overflow: hidden; position: relative; width: 100%; transition: width 0.3s; }
        .top-nav { background: #fff; padding: 10px 20px; border-bottom: 1px solid #dee2e6; display: flex; justify-content: space-between; align-items: center; }
        .content-body { padding: 15px; overflow-y: auto; flex-grow: 1; }
        
        .table-responsive { position: relative; border: 1px solid #dee2e6; border-radius: 4px; background: #fff; }
        thead th { position: sticky; top: 0; background: #f8f9fa !important; z-index: 2; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }
        
        .sql-textarea { 
            font-family: 'Consolas', monospace; 
            font-size: 14px; 
            background: #ffffff; 
            color: var(--bg-dark); 
            border: 2px solid var(--bg-dark); 
            border-top: none; 
        }
        .sql-header-custom {
            background-color: var(--bg-dark);
            color: #fff;
            padding: 12px 20px;
            border-bottom: none;
        }
        
        .badge-pk { background: #e74c3c; font-size: 0.7em; }
        .join-row { background: #f8f9fa; border: 1px solid #eee; padding: 10px; border-radius: 5px; margin-bottom: 10px; }

        .table-item-wrapper, .db-item-wrapper { position: relative; transition: 0.2s; }
        .table-actions, .db-actions { 
            opacity: 0; 
            transition: opacity 0.2s ease;
            pointer-events: none;
        }
        .table-item-wrapper:hover .table-actions, 
        .db-item-wrapper:hover .db-actions { 
            opacity: 1; 
            pointer-events: auto;
        }

        @media(max-width: 768px) {
            .table-actions, .db-actions { opacity: 1; pointer-events: auto; }
            .sidebar { position: fixed; height: 100%; z-index: 1000; margin-left: calc(var(--sidebar-w) * -1); }
            .sidebar.active { margin-left: 0; }
            .sidebar.collapsed { margin-left: calc(var(--sidebar-w) * -1); }
        }

        .stat-card {
 background: #fff; border-radius: 8px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border: 1px solid #eee; }
        .stat-icon { font-size: 2rem; color: #3498db; margin-bottom: 10px; }
        .stat-val { font-size: 1.5rem; font-weight: bold; color: #2c3e50; }
        .stat-label { color: #95a5a6; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 1px; }

        .btn-action { 
            width: 28px; height: 28px; 
            padding: 0; 
            display: inline-flex; 
            align-items: center; 
            justify-content: center; 
            border-radius: 4px;
            transition: 0.2s;
        }
        .btn-action:hover { transform: translateY(-1px); box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        
        .db-link, .table-link { transition: background 0.2s, color 0.2s; }
        
        .action-cell { white-space: nowrap; width: 1%; }

        td {
            max-width: 400px;
            white-space: pre-wrap;
            word-wrap: break-word;
            overflow-y: auto;
            max-height: 200px;
        }
    </style>
</head>
<body>

<div class="sidebar" id="sidebar">
    <div class="sidebar-header d-flex justify-content-between align-items-center">
        <h5 class="m-0"><i class="fas fa-database me-2"></i>DB Master</h5>
        <button class="btn btn-sm btn-outline-light d-md-none" onclick="toggleSidebar()"><i class="fas fa-times"></i></button>
    </div>
    
    <div class="db-list">
        <?php foreach($db_list as $db): ?>
            <div class="db-item-wrapper d-flex align-items-center">
                <a href="?db=<?php echo $db['name']; ?>" class="db-link flex-grow-1 <?php echo ($selected_db == $db['name']) ? 'active' : ''; ?>">
                    <i class="fas fa-server me-2"></i><?php echo $db['name']; ?>
                </a>
                <div class="db-actions pe-3">
                    <a href="?action=drop_db&db=<?php echo $db['name']; ?>" class="text-danger" onclick="return confirm('Drop database <?php echo $db['name']; ?>?')">
                        <i class="fas fa-trash-alt fa-xs"></i>
                    </a>
                </div>
            </div>
            <?php if($selected_db == $db['name']): ?>
                <div class="table-container">
                    <div class="px-3 mb-2">
                        <input type="text" id="tableSearch" class="form-control form-control-sm bg-dark text-white border-secondary" placeholder="Search tables..." onkeyup="filterTables()">
                    </div>
                    <div id="tableListWrapper">
                        <?php if(empty($table_list)): ?>
                            <small class="text-muted ps-4">No tables</small>
                        <?php else: ?>
                            <?php foreach($table_list as $tbl): ?>
                                <div class="table-item-wrapper d-flex align-items-center">
                                    <a href="?db=<?php echo $db['name']; ?>&table=<?php echo $tbl; ?>" class="table-link flex-grow-1 <?php echo ($selected_table == $tbl) ? 'active' : ''; ?>">
                                        <i class="fas fa-table me-2"></i> <?php echo $tbl; ?>
                                    </a>
                                    <div class="pe-2 table-actions">
                                        <a href="?action=truncate_table&db=<?php echo $db['name']; ?>&table=<?php echo $tbl; ?>" class="text-warning me-2" title="Truncate" onclick="return confirm('Truncate table <?php echo $tbl; ?>?')"><i class="fas fa-eraser fa-xs"></i></a>
                                        <a href="?action=drop_table&db=<?php echo $db['name']; ?>&table=<?php echo $tbl; ?>" class="text-danger" title="Drop" onclick="return confirm('Drop table <?php echo $tbl; ?>?')"><i class="fas fa-times fa-xs"></i></a>
                                    </div>
                                </div>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </div>
                </div>
            <?php endif; ?>
        <?php endforeach; ?>
    </div>
</div>

<div class="main">
    <div class="top-nav">
        <div class="d-flex align-items-center">
            <button class="btn btn-link text-dark me-3" onclick="toggleSidebar()">
                <i class="fas fa-bars fa-lg"></i>
            </button>
            <h5 class="m-0">
                <?php if($selected_db): ?>
                    <span class="text-primary"><?php echo $selected_db; ?></span> 
                    <?php if($selected_table): ?> <span class="text-muted">/</span> <?php echo $selected_table; ?> <?php endif; ?>
                <?php else: ?>
                    Dashboard
                <?php endif; ?>
            </h5>
        </div>
        
        <div class="d-flex align-items-center">
            <?php if($selected_db): ?>
                <button class="btn btn-primary btn-sm me-2" data-bs-toggle="modal" data-bs-target="#joinModal">
                    <i class="fas fa-project-diagram me-1"></i> Join Builder
                </button>
            <?php endif; ?>
            <a href="db_ed_new.php" class="btn btn-outline-secondary btn-sm ms-2"><i class="fas fa-sync-alt"></i></a>
        </div>
    </div>

    <div class="content-body">
        
        <?php if($msg): ?>
            <div class="alert alert-<?php echo $msg_type; ?> alert-dismissible fade show shadow-sm">
                <?php echo $msg; ?> <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <?php endif; ?>

        <?php if($selected_db && $selected_table && !$is_custom_query): ?>
            <div class="card mb-3 shadow-sm border-0">
                <div class="card-header bg-white py-2" data-bs-toggle="collapse" data-bs-target="#toolsPanel" style="cursor:pointer">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-primary fw-bold"><i class="fas fa-filter me-2"></i>Advanced Filter & Sort</span>
                        <i class="fas fa-chevron-down text-muted"></i>
                    </div>
                </div>
                <div id="toolsPanel" class="collapse <?php echo (!empty($active_filters_list)) ? 'show' : ''; ?>">
                    <div class="card-body bg-light">
                        <form method="GET" id="filterForm">
                            <input type="hidden" name="db" value="<?php echo $selected_db; ?>">
                            <input type="hidden" name="table" value="<?php echo $selected_table; ?>">
                            
                            <div class="row mb-2">
                                <div class="col-md-10">
                                    <h6 class="text-muted small fw-bold text-uppercase border-bottom pb-1 mb-2">WHERE Conditions (AND)</h6>
                                    <div id="filter-rows-container">
                                        <?php 
                                            $render_rows = !empty($active_filters_list) ? $active_filters_list : [['col'=>'','op'=>'','val'=>'']];
                                            foreach($render_rows as $idx => $flt): 
                                        ?>
                                        <div class="row g-2 align-items-center mb-2 filter-row">
                                            <div class="col-md-4">
                                                <select name="filter_col[]" class="form-select form-select-sm filter-col-select">
                                                    <option value="">Column...</option>
                                                    <?php foreach($structure as $col): ?>
                                                        <option value="<?php echo $col['Field']; ?>" <?php echo ($flt['col'] == $col['Field']) ? 'selected' : ''; ?>><?php echo $col['Field']; ?></option>
                                                    <?php endforeach; ?>
                                                </select>
                                            </div>
                                            <div class="col-md-3">
                                                <select name="filter_op[]" class="form-select form-select-sm filter-op-select" onchange="toggleValueInput(this)">
                                                    <option value="">Op...</option>
                                                    <optgroup label="Basic">
                                                        <option value="EQ" <?php echo ($flt['op'] == 'EQ') ? 'selected' : ''; ?>>= Equals</option>
                                                        <option value="NEQ" <?php echo ($flt['op'] == 'NEQ') ? 'selected' : ''; ?>>!= Not Equals</option>
                                                    </optgroup>
                                                    <optgroup label="Matching">
                                                        <option value="LIKE" <?php echo ($flt['op'] == 'LIKE') ? 'selected' : ''; ?>>LIKE</option>
                                                        <option value="NOT_LIKE" <?php echo ($flt['op'] == 'NOT_LIKE') ? 'selected' : ''; ?>>NOT LIKE</option>
                                                    </optgroup>
                                                    <optgroup label="Range">
                                                        <option value="GT" <?php echo ($flt['op'] == 'GT') ? 'selected' : ''; ?>>&gt; Greater</option>
                                                        <option value="GTE" <?php echo ($flt['op'] == 'GTE') ? 'selected' : ''; ?>>&ge; Greater/Eq</option>
                                                        <option value="LT" <?php echo ($flt['op'] == 'LT') ? 'selected' : ''; ?>>&lt; Less</option>
                                                        <option value="LTE" <?php echo ($flt['op'] == 'LTE') ? 'selected' : ''; ?>>&le; Less/Eq</option>
                                                    </optgroup>
                                                    <optgroup label="List & Nulls">
                                                        <option value="IN" <?php echo ($flt['op'] == 'IN') ? 'selected' : ''; ?>>IN (1,2,3)</option>
                                                        <option value="NOT_IN" <?php echo ($flt['op'] == 'NOT_IN') ? 'selected' : ''; ?>>NOT IN</option>
                                                        <option value="IS_NULL" <?php echo ($flt['op'] == 'IS_NULL') ? 'selected' : ''; ?>>IS NULL</option>
                                                        <option value="NOT_NULL" <?php echo ($flt['op'] == 'NOT_NULL') ? 'selected' : ''; ?>>IS NOT NULL</option>
                                                    </optgroup>
                                                </select>
                                            </div>
                                            <div class="col-md-4">
                                                <input type="text" name="filter_val[]" class="form-control form-control-sm filter-val-input" placeholder="Value..." value="<?php echo htmlspecialchars($flt['val']); ?>">
                                            </div>
                                            <div class="col-md-1">
                                                <button type="button" class="btn btn-outline-danger btn-sm w-100" onclick="removeFilterRow(this)" title="Remove condition"><i class="fas fa-times"></i></button>
                                            </div>
                                        </div>
                                        <?php endforeach; ?>
                                    </div>
                                    <button type="button" class="btn btn-outline-success btn-sm mt-1" onclick="addFilterRow()"><i class="fas fa-plus me-1"></i> Add Condition</button>
                                </div>
                                
                                <div class="col-md-2 border-start">
                                    <h6 class="text-muted small fw-bold text-uppercase border-bottom pb-1 mb-2">Sorting & Limit</h6>
                                    <div class="mb-2">
                                        <label class="small text-muted mb-1">Sort By</label>
                                        <select name="sort_col" class="form-select form-select-sm mb-1">
                                            <option value="">None</option>
                                            <?php foreach($structure as $col): ?>
                                                <option value="<?php echo $col['Field']; ?>" <?php echo (isset($active_sort['col']) && $active_sort['col'] == $col['Field']) ? 'selected' : ''; ?>><?php echo $col['Field']; ?></option>
                                            <?php endforeach; ?>
                                        </select>
                                        <select name="sort_dir" class="form-select form-select-sm">
                                            <option value="ASC" <?php echo (isset($active_sort['dir']) && $active_sort['dir'] == 'ASC') ? 'selected' : ''; ?>>ASC</option>
                                            <option value="DESC" <?php echo (isset($active_sort['dir']) && $active_sort['dir'] == 'DESC') ? 'selected' : ''; ?>>DESC</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="small text-muted mb-1">Limit</label>
                                        <input type="number" name="limit" class="form-control form-control-sm" value="<?php echo $limit; ?>">
                                    </div>
                                    <div class="d-grid gap-2">
                                        <button type="submit" class="btn btn-primary btn-sm">Apply</button>
                                        <a href="?db=<?php echo $selected_db; ?>&table=<?php echo $selected_table; ?>" class="btn btn-outline-secondary btn-sm">Reset</a>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        <?php endif; ?>

        <?php if($selected_db && !empty($columns)): ?>
            <div class="card shadow-sm mb-4" style="min-height: 400px; display: flex; flex-direction: column;">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <div class="d-flex align-items-center flex-grow-1">
                        <ul class="nav nav-pills card-header-pills">
                            <li class="nav-item">
                                <a class="nav-link active py-1 px-3" href="#" id="btn-view-data" onclick="toggleView('data'); return false;"><i class="fas fa-list me-1"></i> Data</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link py-1 px-3" href="#" id="btn-view-struct" onclick="toggleView('struct'); return false;"><i class="fas fa-columns me-1"></i> Structure</a>
                            </li>
                            <li class="nav-item ms-2">
                                <button class="btn btn-sm btn-success py-1 px-3" data-bs-toggle="modal" data-bs-target="#insertModal"><i class="fas fa-plus me-1"></i> Insert Data</button>
                            </li>
                        </ul>
                        <div class="ms-3">
                             <input type="text" class="form-control form-control-sm border-secondary" style="width: 200px;" placeholder="Quick JS Filter..." id="js-table-search">
                        </div>
                    </div>
                    
                    <div class="d-flex align-items-center">
                        <span class="badge bg-light text-dark border align-middle me-2"><?php echo $total_rows; ?> Rows</span>
                        <?php if($total_pages > 1): ?>
                            <div class="btn-group btn-group-sm">
                                <a href="<?php echo build_url(max(1, $page-1), $limit, $global_search); ?>" class="btn btn-outline-secondary <?php echo ($page<=1)?'disabled':''; ?>"><i class="fas fa-chevron-left"></i></a>
                                <span class="btn btn-outline-secondary disabled">Pg <?php echo $page; ?>/<?php echo $total_pages; ?></span>
                                <a href="<?php echo build_url(min($total_pages, $page+1), $limit, $global_search); ?>" class="btn btn-outline-secondary <?php echo ($page>=$total_pages)?'disabled':''; ?>"><i class="fas fa-chevron-right"></i></a>
                            </div>
                        <?php endif; ?>
                    </div>
                </div>
                
                <div class="table-responsive flex-grow-1 border-0" id="view-data">
                    <table class="table table-hover table-bordered table-striped mb-0" style="font-size: 0.9rem;">
                        <thead class="table-light">
                            <tr>
                                <th class="action-cell">Actions</th>
                                <?php foreach($columns as $col): ?>
                                    <th style="min-width: 100px; white-space: nowrap;">
                                        <?php echo $col['Field']; ?>
                                        <span class="text-muted fw-normal" style="font-size: 0.75em; display:block;"><?php echo $col['Type']; ?></span>
                                    </th>
                                <?php endforeach; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if(empty($rows)): ?>
                                <tr><td colspan="<?php echo count($columns) + 1; ?>" class="text-center p-5 text-muted">No data found.</td></tr>
                            <?php else: ?>
                                <?php foreach($rows as $row): ?>
                                    <tr>
                                        <td class="action-cell">
                                            <div class="d-flex gap-1">
                                                <button class="btn btn-primary btn-action" onclick='editRow(<?php echo json_encode($row); ?>)' title="Edit"><i class="fas fa-edit"></i></button>
                                                <form method="POST" onsubmit="return confirm('Delete this row?')" class="m-0">
                                                    <input type="hidden" name="db" value="<?php echo $selected_db; ?>">
                                                    <input type="hidden" name="table" value="<?php echo $selected_table; ?>">
                                                    <input type="hidden" name="pk_col" value="<?php echo $primary_key; ?>">
                                                    <input type="hidden" name="pk_val" value="<?php echo isset($row[$primary_key]) ? htmlspecialchars($row[$primary_key]) : ''; ?>">
                                                    <button type="submit" name="delete_row" class="btn btn-danger btn-action" <?php echo !$primary_key ? 'disabled title="No Primary Key"' : ''; ?>><i class="fas fa-trash"></i></button>
                                                </form>
                                            </div>
                                        </td>
                                        <?php foreach($row as $val): ?>
                                            <td>
                                                <?php 
                                                    if($val === NULL) echo '<span class="badge bg-secondary opacity-50">NULL</span>';
                                                    else echo nl2br(htmlspecialchars($val)); 
                                                ?>
                                            </td>
                                        <?php endforeach; ?>
                                    </tr>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>

                <div class="table-responsive flex-grow-1 border-0 d-none" id="view-struct">
                    <table class="table table-hover table-bordered mb-0">
                        <thead class="table-secondary">
                            <tr>
                                <th>Name</th>
                                <th>Type</th>
                                <th>Null</th>
                                <th>Key</th>
                                <th>Default</th>
                                <th>Extra</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if(!empty($structure)): ?>
                                <?php foreach($structure as $st): ?>
                                    <tr>
                                        <td class="fw-bold"><?php echo $st['Field']; ?></td>
                                        <td class="text-primary"><?php echo $st['Type']; ?></td>
                                        <td><?php echo $st['Null']; ?></td>
                                        <td><?php echo ($st['Key'] == 'PRI') ? '<span class="badge badge-pk">PRIMARY</span>' : $st['Key']; ?></td>
                                        <td><?php echo $st['Default']; ?></td>
                                        <td><?php echo $st['Extra']; ?></td>
                                    </tr>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        <?php elseif(!$selected_db): ?>
             <div class="container-fluid py-4">
                <div class="row g-4 mb-4">
                    <div class="col-md-4">
                        <div class="stat-card">
                            <i class="fas fa-server stat-icon"></i>
                            <div class="stat-val"><?php echo $server_stats['version']; ?></div>
                            <div class="stat-label">MySQL Version</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stat-card">
                            <i class="fas fa-clock stat-icon" style="color:#2ecc71"></i>
                            <div class="stat-val"><?php echo round($server_stats['uptime'] / 3600, 1); ?> hrs</div>
                            <div class="stat-label">Server Uptime</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stat-card">
                            <i class="fas fa-plug stat-icon" style="color:#e67e22"></i>
                            <div class="stat-val"><?php echo $server_stats['threads']; ?></div>
                            <div class="stat-label">Active Connections</div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-8">
                        <div class="card shadow-sm border-0">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                                <h6 class="m-0 fw-bold text-primary"><i class="fas fa-database me-2"></i>Databases</h6>
                                <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#createDbModal">
                                    <i class="fas fa-plus me-1"></i> New Database
                                </button>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Database Name</th>
                                                <th>Tables</th>
                                                <th>Size</th>
                                                <th class="text-end">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php foreach($db_list as $db): ?>
                                                <tr>
                                                    <td><a href="?db=<?php echo $db['name']; ?>" class="fw-bold text-decoration-none"><?php echo $db['name']; ?></a></td>
                                                    <td><span class="badge bg-light text-dark border"><?php echo $db['tables']; ?></span></td>
                                                    <td><small class="text-muted"><?php echo $db['size']; ?></small></td>
                                                    <td class="text-end">
                                                        <div class="d-flex justify-content-end gap-2">
                                                            <a href="?action=export&db=<?php echo $db['name']; ?>" class="btn btn-outline-secondary btn-action" title="Export SQL"><i class="fas fa-download fa-xs"></i></a>
                                                            <a href="?action=drop_db&db=<?php echo $db['name']; ?>" class="btn btn-outline-danger btn-action" onclick="return confirm('Drop database <?php echo $db['name']; ?>?')" title="Drop"><i class="fas fa-trash-alt fa-xs"></i></a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card shadow-sm border-0 mb-4">
                            <div class="card-header bg-white py-3">
                                <h6 class="m-0 fw-bold text-primary"><i class="fas fa-file-import me-2"></i>Quick Import</h6>
                            </div>
                            <div class="card-body">
                                <form method="POST" enctype="multipart/form-data">
                                    <div class="mb-3">
                                        <label class="form-label small text-muted">Target Database</label>
                                        <select name="target_db" class="form-select form-select-sm">
                                            <option value="">(None)</option>
                                            <?php foreach($db_list as $db): ?>
                                                <option value="<?php echo $db['name']; ?>"><?php echo $db['name']; ?></option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label small text-muted">SQL File</label>
                                        <input type="file" name="sql_file" class="form-control form-control-sm" accept=".sql">
                                    </div>
                                    <button type="submit" name="import_sql" class="btn btn-success btn-sm w-100">Upload & Import</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        <?php endif; ?>
        
        <div class="card shadow-sm mt-auto border-0 mb-3">
            <div class="card-header sql-header-custom d-flex justify-content-between align-items-center rounded-top">
                <span class="fw-bold"><i class="fas fa-terminal me-2"></i>SQL Console</span>
                <small class="text-white-50">Target: <?php echo $selected_db ? $selected_db : 'None'; ?></small>
            </div>
            <div class="card-body p-0">
                <form method="POST">
                    <input type="hidden" name="target_db" value="<?php echo $selected_db; ?>">
                    <textarea name="sql_query" id="main_sql_textarea" class="form-control sql-textarea p-3 rounded-0" rows="4" placeholder="SELECT * FROM table WHERE id = 1;"><?php echo htmlspecialchars($sql_query_input); ?></textarea>
                    <div class="bg-light p-3 text-end border-top border-2 border-secondary d-flex justify-content-end align-items-center gap-2" style="border-color: var(--bg-dark) !important;">
                         <small class="text-muted me-auto">Use Ctrl+Enter to execute</small>
                        <button type="submit" name="run_sql" class="btn btn-dark btn-sm px-4 fw-bold" style="background-color: var(--bg-dark); border-color: var(--bg-dark);">Execute Query</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-edit me-2"></i>Edit Row</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST">
                <div class="modal-body bg-light">
                    <input type="hidden" name="target_db" value="<?php echo $selected_db; ?>">
                    <input type="hidden" name="target_table" value="<?php echo $selected_table; ?>">
                    <input type="hidden" name="pk_col" value="<?php echo $primary_key; ?>">
                    <input type="hidden" name="pk_val" id="edit_pk_val">
                    
                    <div id="edit-fields-container" class="row g-3"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" name="update_row_submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="createDbModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-plus-circle me-2"></i>Create New Database</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Database Name</label>
                        <input type="text" name="db_name" class="form-control" placeholder="my_new_database" required pattern="[a-zA-Z0-9_]+">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" name="create_db" class="btn btn-primary">Create Database</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="insertModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-plus-circle me-2"></i>Insert into `<?php echo $selected_table; ?>`</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST">
                <div class="modal-body bg-light">
                    <input type="hidden" name="target_db" value="<?php echo $selected_db; ?>">
                    <input type="hidden" name="target_table" value="<?php echo $selected_table; ?>">
                    
                    <div id="insert-rows-container"></div>
                    
                    <div class="text-center mt-3">
                        <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" onclick="addInsertRow()">
                            <i class="fas fa-plus"></i> Add Another Row
                        </button>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" name="insert_data_submit" class="btn btn-success">Save Data</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="joinModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title"><i class="fas fa-project-diagram me-2"></i>Visual Join Query Builder</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body bg-light">
                <div class="row">
                    <div class="col-md-8 border-end">
                        <h6 class="text-primary fw-bold mb-3">1. Table Relationships</h6>
                        <div class="card mb-3 shadow-sm border-primary">
                            <div class="card-body p-2 d-flex align-items-center">
                                <span class="fw-bold me-2">FROM</span>
                                <select id="jb_base_table" class="form-select form-select-sm fw-bold" onchange="updateColumnSelectors()">
                                </select>
                            </div>
                        </div>
                        <div id="jb_joins_container"></div>
                        <button type="button" class="btn btn-sm btn-outline-success mt-2" onclick="addJoinRow()">
                            <i class="fas fa-plus"></i> Add Join
                        </button>
                    </div>
                    <div class="col-md-4">
                        <h6 class="text-primary fw-bold mb-3">2. Select Columns</h6>
                        <div class="card shadow-sm" style="height: 300px; overflow-y: auto;">
                            <div class="card-body p-2" id="jb_columns_container">
                                <small class="text-muted">Select tables first...</small>
                            </div>
                        </div>
                        <div class="mt-2 text-end">
                            <button class="btn btn-sm btn-outline-secondary" onclick="selectAllColumns(true)">All</button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="selectAllColumns(false)">None</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary fw-bold" onclick="generateJoinQuery()">
                    <i class="fas fa-code me-2"></i>Generate to Console
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const dbSchema = <?php echo $db_schema_json; ?>;
    const currentTable = "<?php echo $selected_table; ?>";

    function toggleSidebar() { 
        const sidebar = document.getElementById('sidebar');
        if(window.innerWidth < 768) { sidebar.classList.toggle('active'); } 
        else { sidebar.classList.toggle('collapsed'); }
    }

    function filterTables() {
        var input = document.getElementById("tableSearch");
        var filter = input.value.toUpperCase();
        var a = document.getElementById("tableListWrapper").getElementsByClassName("table-link");
        for (var i = 0; i < a.length; i++) {
            var txtValue = a[i].textContent || a[i].innerText;
            a[i].style.display = txtValue.toUpperCase().indexOf(filter) > -1 ? "block" : "none";
        }
    }

    const quickSearchInput = document.getElementById('js-table-search');
    if(quickSearchInput) {
        quickSearchInput.addEventListener('keyup', function() {
            var value = this.value.toLowerCase();
            var rows = document.querySelectorAll('#view-data tbody tr');
            rows.forEach(function(row) {
                var text = row.textContent.toLowerCase();
                row.style.display = text.indexOf(value) > -1 ? '' : 'none';
            });
        });
    }

    function toggleValueInput(selectEl) {
        const row = selectEl.closest('.filter-row');
        if(!row) return;
        
        const op = selectEl.value;
        const input = row.querySelector('.filter-val-input');
        
        if(op === 'IS_NULL' || op === 'NOT_NULL') {
            input.disabled = true;
            input.value = '';
            input.placeholder = 'Value ignored';
        } else if (op === 'IN' || op === 'NOT_IN') {
             input.disabled = false;
             input.placeholder = 'e.g. 1, 5, 20';
        } else {
            input.disabled = false;
            input.placeholder = 'Value...';
        }
    }
    
    document.addEventListener('DOMContentLoaded', function(){
        document.querySelectorAll('.filter-op-select').forEach(sel => toggleValueInput(sel));
    });

    function addFilterRow() {
        const container = document.getElementById('filter-rows-container');

        const template = container.querySelector('.filter-row');
        if(template) {
            const newRow = template.cloneNode(true);
            newRow.querySelector('.filter-col-select').value = '';
            newRow.querySelector('.filter-op-select').value = '';
            const valInput = newRow.querySelector('.filter-val-input');
            valInput.value = '';
            valInput.disabled = false;
            valInput.placeholder = 'Value...';
            
            container.appendChild(newRow);
        }
    }

    function removeFilterRow(btn) {
        const container = document.getElementById('filter-rows-container');
        if(container.querySelectorAll('.filter-row').length > 1) {
            btn.closest('.filter-row').remove();
        } else {
            const row = btn.closest('.filter-row');
            row.querySelector('.filter-col-select').value = '';
            row.querySelector('.filter-op-select').value = '';
            row.querySelector('.filter-val-input').value = '';
        }
    }

    const primaryKey = "<?php echo $primary_key; ?>";
    function editRow(rowData) {
        const container = document.getElementById('edit-fields-container');
        container.innerHTML = '';
        document.getElementById('edit_pk_val').value = rowData[primaryKey] || '';
        
        for (const [col, val] of Object.entries(rowData)) {
            const div = document.createElement('div');
            div.className = 'col-md-6';
            div.innerHTML = `
                <label class="form-label small text-muted mb-0 fw-bold">${col}</label>
                <textarea name="upd_data[${col}]" class="form-control form-control-sm" rows="1">${val || ''}</textarea>
            `;
            container.appendChild(div);
        }
        
        const editModal = new bootstrap.Modal(document.getElementById('editModal'));
        editModal.show();
    }

    const structureSql = <?php echo json_encode($create_table_sql); ?>;
    function toggleView(view) {
        var dataDiv = document.getElementById('view-data');
        var structDiv = document.getElementById('view-struct');
        var btnData = document.getElementById('btn-view-data');
        var btnStruct = document.getElementById('btn-view-struct');
        var sqlTextarea = document.querySelector('textarea[name="sql_query"]');

        if(view === 'data') {
            dataDiv.classList.remove('d-none');
            structDiv.classList.add('d-none');
            btnData.classList.add('active');
            btnStruct.classList.remove('active');
        } else {
            dataDiv.classList.add('d-none');
            structDiv.classList.remove('d-none');
            btnData.classList.remove('active');
            btnStruct.classList.add('active');
            if(sqlTextarea) sqlTextarea.value = structureSql;
        }
    }

    <?php if(!empty($structure)): ?>
    let rowCount = 0;
    const columns = <?php echo json_encode($structure); ?>;
    function addInsertRow() {
        const container = document.getElementById('insert-rows-container');
        const rowDiv = document.createElement('div');
        rowDiv.className = 'card mb-3 shadow-sm border-start border-4 border-primary';
        let html = '<div class="card-body p-3"><div class="row g-2">';
        html += '<div class="col-12 text-end"><button type="button" class="btn btn-sm text-danger p-0" onclick="this.closest(\'.card\').remove()"><i class="fas fa-times"></i> Remove Row</button></div>';
        columns.forEach(col => {
            const fieldName = col.Field;
            const fieldType = col.Type;
            let inputType = 'text';
            if(fieldType.includes('int') || fieldType.includes('decimal')) inputType = 'number';
            if(fieldType.includes('date')) inputType = 'date';
            if(fieldType.includes('text')) inputType = 'textarea';

            html += `<div class="col-md-3 mb-2"><label class="form-label small text-muted mb-0 fw-bold">${fieldName}</label>`;
            if(inputType === 'textarea') {
                html += `<textarea name="ins_data[${rowCount}][${fieldName}]" class="form-control form-control-sm" rows="1"></textarea>`;
            } else {
                html += `<input type="${inputType}" name="ins_data[${rowCount}][${fieldName}]" class="form-control form-control-sm">`;
            }
            html += `</div>`;
        });
        html += '</div></div>';
        rowDiv.innerHTML = html;
        container.appendChild(rowDiv);
        rowCount++;
    }
    document.addEventListener('DOMContentLoaded', function() { if(document.getElementById('insert-rows-container')) addInsertRow(); });
    <?php endif; ?>

    const baseTableSelect = document.getElementById('jb_base_table');
    if(baseTableSelect) {
        for (const tbl in dbSchema) {
            let opt = document.createElement('option');
            opt.value = tbl; opt.text = tbl;
            if(tbl === currentTable) opt.selected = true;
            baseTableSelect.appendChild(opt);
        }
        setTimeout(updateColumnSelectors, 500); 
    }

    function addJoinRow() {
        const container = document.getElementById('jb_joins_container');
        const rowId = 'join_row_' + Math.random().toString(36).substr(2, 9);
        let html = `
        <div class="join-row d-flex align-items-center gap-2" id="${rowId}">
            <select class="form-select form-select-sm" style="width:100px;">
                <option value="JOIN">JOIN</option>
                <option value="LEFT JOIN">LEFT</option>
                <option value="RIGHT JOIN">RIGHT</option>
            </select>
            <select class="form-select form-select-sm jb-table-select" style="width:150px;" onchange="updateColumnSelectors()">
                ${getOptionsForTables()}
            </select>
            <span class="fw-bold">ON</span>
            <select class="form-select form-select-sm jb-col-select"><option value="">Col...</option></select>
            <span class="fw-bold">=</span>
            <select class="form-select form-select-sm jb-col-select"><option value="">Col...</option></select>
            <button class="btn btn-sm btn-light text-danger" onclick="document.getElementById('${rowId}').remove(); updateColumnSelectors();"><i class="fas fa-times"></i></button>
        </div>`;
        container.insertAdjacentHTML('beforeend', html);
        updateConditionDropdowns(document.getElementById(rowId));
    }

    function getOptionsForTables() {
        let opts = '';
        for (const tbl in dbSchema) { opts += `<option value="${tbl}">${tbl}</option>`; }
        return opts;
    }

    function updateColumnSelectors() {
        let selectedTables = [document.getElementById('jb_base_table').value];
        document.querySelectorAll('.jb-table-select').forEach(sel => selectedTables.push(sel.value));
        const colContainer = document.getElementById('jb_columns_container');
        colContainer.innerHTML = '';
        
        selectedTables.forEach(tbl => {
            if(dbSchema[tbl]) {
                let group = document.createElement('div');
                group.className = 'mb-2';
                group.innerHTML = `<strong class="small text-muted border-bottom d-block mb-1">${tbl}</strong>`;
                dbSchema[tbl].forEach(col => {
                    let checkId = `chk_${tbl}_${col}`;
                    group.innerHTML += `
                    <div class="form-check form-check-sm">
                        <input class="form-check-input col-chk" type="checkbox" value="${tbl}.${col}" id="${checkId}">
                        <label class="form-check-label" for="${checkId}">${col}</label>
                    </div>`;
                });
                colContainer.appendChild(group);
            }
        });
        document.querySelectorAll('.join-row').forEach(row => updateConditionDropdowns(row));
    }

    function updateConditionDropdowns(rowDiv) {
        let allCols = [];
        for(const tbl in dbSchema) {
            dbSchema[tbl].forEach(c => allCols.push({val: `${tbl}.${c}`, txt: `${tbl}.${c}`}));
        }
        let selects = rowDiv.querySelectorAll('.jb-col-select');
        selects.forEach(sel => {
            let currentVal = sel.value;
            sel.innerHTML = '<option value="">Select Col...</option>';
            allCols.forEach(c => {
                let opt = document.createElement('option');
                opt.value = c.val; opt.text = c.txt;
                if(c.val === currentVal) opt.selected = true;
                sel.appendChild(opt);
            });
        });
    }

    function selectAllColumns(check) { document.querySelectorAll('.col-chk').forEach(el => el.checked = check); }

    function generateJoinQuery() {
        let selectedCols = [];
        document.querySelectorAll('.col-chk:checked').forEach(chk => selectedCols.push(chk.value));
        let selectStr = selectedCols.length > 0 ? selectedCols.join(', ') : '*';
        let baseTable = document.getElementById('jb_base_table').value;
        let query = `SELECT ${selectStr}\nFROM ${baseTable}`;
        document.querySelectorAll('.join-row').forEach(row => {
            let type = row.querySelector('select:nth-child(1)').value;
            let tbl = row.querySelector('.jb-table-select').value;
            let col1 = row.querySelectorAll('.jb-col-select')[0].value;
            let col2 = row.querySelectorAll('.jb-col-select')[1].value;
            if(tbl && col1 && col2) { query += `\n${type} ${tbl} ON ${col1} = ${col2}`; }
        });
        const modalEl = document.getElementById('joinModal');
        const modal = bootstrap.Modal.getInstance(modalEl);
        modal.hide();
        const textArea = document.getElementById('main_sql_textarea');
        textArea.value = query;
        textArea.focus();
    }
</script>
</body>
</html>