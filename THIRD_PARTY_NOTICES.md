# Third-Party Notices

SQL Lab itself is licensed under the MIT License in [`LICENSE.md`](LICENSE.md).

The optional sample databases described below are third-party works with their
own license terms. Their SQL files are downloaded locally by explicit
`make samples-*` commands and are excluded from Git. They are not relicensed
under the SQL Lab license.

## Chinook Database

- Upstream: `lerocha/chinook-database`
- Pinned revision:
  `4a944a942426e1f3263fe539155fb7ef92b04b4a`
- Files used:
  - `ChinookDatabase/DataSources/Chinook_MySql.sql`
  - `ChinookDatabase/DataSources/Chinook_PostgreSql.sql`
  - `LICENSE.md`
- Integrity:
  - license Git blob:
    `7487a9edc2d42e50d7a38ab1fbdba33ac63230f7`
  - MySQL SQL Git blob:
    `cdbd482f1be7fde54644480ec7c794ff2764b109`
  - PostgreSQL SQL Git blob:
    `d93a20d08239ac6bdd8a56601e148f5d4d048593`

The complete upstream license notice is inserted into each locally prepared
Chinook SQL file.

### Chinook license notice

Chinook Database

Copyright (c) 2008-2024 Luis Rocha

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Pagila

- Upstream: `devrimgunduz/pagila`
- Pinned revision:
  `5ba5a57aeb159f75f02aca2432d3c262186d13d3`
- Files used:
  - `pagila-schema.sql`
  - `pagila-data.sql`
  - `LICENSE.txt`
- Integrity:
  - license Git blob:
    `c6078c708c6f55b56e24f3687c591ca12df567ca`
  - schema Git blob:
    `23718a3adef90ced002e19ad4e1ac98d22aa5870`
  - data Git blob:
    `b7c016861fd0f84008645153c6a1d9e5a99b9cc6`

The pinned upstream README describes Pagila as being available under the
PostgreSQL License, while the pinned `LICENSE.txt` contains the permission text
reproduced below. SQL Lab preserves that exact upstream text without assigning
a different SPDX identifier. The complete notice is inserted into both locally
prepared Pagila SQL files.

### Pagila license notice

Copyright (c) Devrim Gündüz <devrim@gunduz.org>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Sakila Sample Database

- Official archive:
  `https://downloads.mysql.com/docs/sakila-db.zip`
- Verified archive SHA-256:
  `c2ecb3dec28d752241ccfca02974ba970de3c3fc5d98887fd3f9d5843f946672`
- Files used:
  - `sakila-schema.sql`
  - `sakila-data.sql`
- Official license reference:
  `https://dev.mysql.com/doc/sakila/en/sakila-license.html`

MySQL states that `sakila-schema.sql` and `sakila-data.sql` are licensed under
the New BSD license. Other materials in the distribution are not covered by
that open license.

SQL Lab extracts only those two SQL files. It does not publish the Sakila
documentation or `sakila.mwb`. Before extraction, the archive SHA-256 is
verified. Both SQL files must contain the expected New BSD notice and
disclaimer, and they are copied without modifying their embedded copyright and
license text.
