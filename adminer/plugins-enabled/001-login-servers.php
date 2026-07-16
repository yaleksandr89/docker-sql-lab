<?php

require_once('plugins/login-servers.php');

return new AdminerLoginServers([
    'MySQL (mysql)' => [
        'server' => 'mysql',
        'driver' => 'server',
    ],
    'PostgreSQL (postgres)' => [
        'server' => 'postgres',
        'driver' => 'pgsql',
    ],
]);
