<?php

require_once('plugins/login-servers.php');
require_once('plugins/drivers/clickhouse.php');

return new AdminerLoginServers([
    'MySQL (mysql)' => [
        'server' => 'mysql',
        'driver' => 'server',
    ],
    'PostgreSQL (postgres)' => [
        'server' => 'postgres',
        'driver' => 'pgsql',
    ],
    'ClickHouse (clickhouse)' => [
        'server' => 'clickhouse:8123',
        'driver' => 'clickhouse',
    ],
]);
