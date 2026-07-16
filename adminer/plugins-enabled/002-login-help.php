<?php

return new class {
    public function loginForm(): void
    {
        echo <<<'HTML'
<div style="display: flow-root;">
<fieldset>
<legend>Как войти</legend>
<p>Выберите MySQL (mysql) или PostgreSQL (postgres).</p>
<p>Имя пользователя и пароль — значения <code>DB_USER</code> и <code>DB_PASSWORD</code> из файла <code>.docker.env</code>.</p>
<p>Основная база — <code>demo</code>. Для MySQL также доступны <code>world</code> и <code>sakila</code>, если установлены optional samples.</p>
<p>Административные пользователи для обычной учебной работы не требуются.</p>
</fieldset>
</div>
HTML;
    }
};
