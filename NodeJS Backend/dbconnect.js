const pgPromise = require('pg-promise');

const pgp = pgPromise({});

const config = {
    host: '35.230.79.137',
    port: 5432,
    database: 'data-at-rest_QA-1',
    user: 'fanx-master',
    password: 'fanxrulez'
};

const db = pgp(config);

exports.db = db;