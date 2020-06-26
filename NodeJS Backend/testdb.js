const { db } = require('./dbconnect');

const query = 'SELECT x.id FROM public."metrics-details-sink" x WHERE id > 3381000 AND id < 3382000 AND "MetricsDetails_metrics_nname" = \'service\'';

db.any(query)
    .then(res => {
        console.log(res);
    });