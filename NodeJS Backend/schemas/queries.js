const { db } = require("../dbconnect");
const { GraphQLObjectType, GraphQLID, GraphQLList, GraphQLString, GraphQLInt, GraphQLScalarType } = require("graphql");
const { MetricsType } = require("./metricsTypes");
const { NpsType } = require("./npsTypes");

const RootQuery = new GraphQLObjectType({
    name: "RootQueryType",
    type: "Query",
    fields: {
        metrics:{
            type: new GraphQLList(MetricsType),
            args: { day : {type: GraphQLInt}, name: {type: GraphQLString}, label: {type: GraphQLString} },
            async resolve(parent, args){
                const query = `SELECT extract(hour from x."completedDateTime") as "hour", avg ("MetricsDetails_metrics_score") as "avgScore"
                from public."metrics-details-sink" x
                where "MetricsDetails_listeningPost_label"  = $3 and "MetricsDetails_metrics_nname" = $2  and extract(day from x."completedDateTime") = $1
                group by extract (hour from x."completedDateTime")`;
                const values = [args.day, args.name, args.label];
                const res = await db.any(query, values);
                return res;
            },
        },
        distinctLabelsQuery:{
            type: new GraphQLList(MetricsType),
            args: {},
            async resolve(parent, args){
                const query = `SELECT distinct(x."MetricsDetails_listeningPost_label") as "distinctLabel" FROM public."metrics-details-sink" x`;
                const res = await db.any(query);
                return res;
            }
        },
        distinctNamesQuery:{
            type: new GraphQLList(MetricsType),
            args: {},
            async resolve(parent, args){
                const query = `SELECT distinct(x."MetricsDetails_metrics_nname" ) as "distinctName" FROM public."metrics-details-sink" x`;
                const res = await db.any(query);
                return res;
            }
        },
        distinctDaysQuery:{
            type: new GraphQLList(MetricsType),
            args: {},
            async resolve(parent, args){
                const query = `SELECT distinct(extract (day from x."completedDateTime")) as "distinctDay" FROM public."metrics-details-sink" x order by extract(day from x."completedDateTime" )`;
                const res = await db.any(query);
                return res;
            }
        },
        getPieChartData:{
            type: new GraphQLList(MetricsType),
            args: { day : {type: GraphQLInt}, name: {type: GraphQLString}, label: {type: GraphQLString} },
            async resolve(parent, args){
                const query = `select x."MetricsDetails_metrics_label_name" as "labelName", round(sum(x."MetricsDetails_metrics_label_count") * 100.0 / 
                nullif ((select sum(y."MetricsDetails_metrics_label_count") from public."metrics-details-sink" y where y."MetricsDetails_listeningPost_label"  = $3 and y."MetricsDetails_metrics_nname" = $2 and extract(day from y."completedDateTime") = $1),0)) as "labelPercent"
                from public."metrics-details-sink" x where x."MetricsDetails_listeningPost_label" = $3
                and x."MetricsDetails_metrics_nname" = $2
                and extract (day from x."completedDateTime") = $1
                group by x."MetricsDetails_metrics_label_name" `
                const values = [args.day, args.name, args.label];
                const res = await db.any(query, values);
                return res;
            }
        },
        distinctDayNPS:{
            type: new GraphQLList(NpsType),
            args: {},
            async resolve (parent, args){
                const query = `SELECT distinct (extract (day from x."completedDateTime")) as "distinctDay"
                 FROM public."metrics-details-summary-sink" x
                 where x."metricsDetailsSummary_metrics_name" = 'nps' 
                 order by extract (day from x."completedDateTime")`;
                const res = await db.any(query);
                return res;
            }
        },
        npsMetrics:{
            type: new GraphQLList(NpsType),
            args: { day: {type: GraphQLInt}},
            async resolve(parents, args){
                const query =  `SELECT extract(hour from x."completedDateTime") as "hour", avg (x."metricsDetailsSummary_metrics_score" ) as "avgScore"
                from public."metrics-details-summary-sink" x
                where x."metricsDetailsSummary_metrics_name" = 'nps'  and extract(day from x."completedDateTime") = $1
                group by extract (hour from x."completedDateTime")`;

                const values = [args.day];
                const res = await db.any(query,values);
                return res;
            }
        },
        npsMetricsDay:{
            type: new GraphQLList(NpsType),
            args: { day: {type: GraphQLInt}},
            async resolve(parents, args){
                const query = `SELECT  round (avg (x."metricsDetailsSummary_metrics_score")) as "avgScoreDay"
                from public."metrics-details-summary-sink" x
                where x."metricsDetailsSummary_metrics_name" = 'nps'  and extract(day from x."completedDateTime") = $1`;
                const values = [args.day];
                const res = await db.any(query, values);
                return res;
            }
        },
        npsDistinctLabelName:{
            type: new GraphQLList(NpsType),
            async resolve (parent, args){
                const query = `SELECT distinct (x."metricsDetailsSummary_metrics_label_name" ) as "distinctLabel"
                FROM public."metrics-details-summary-sink" x
                where x."metricsDetailsSummary_metrics_name" = 'nps'`;

                const res = await db.any(query);
                return res;
            }
        },
        npsDistinctScores:{
            type: new GraphQLList(NpsType),
            args: { day: {type: GraphQLInt}, label: {type: GraphQLString}},
            async resolve (parent, args){
                const query = `SELECT sum("metricsDetailsSummary_metrics_label_count") as "distinctContributorsCount", extract(hour from x."completedDateTime") as "hour"
                FROM public."metrics-details-summary-sink" x
                where extract(day from x."completedDateTime") = $1 and x."metricsDetailsSummary_metrics_name" = 'nps' and x."metricsDetailsSummary_metrics_label_name" = $2
                group by extract(hour from x."completedDateTime")`;

                const values = [args.day, args.label];
                const res = await db.any(query,values);
                return res;
            }
        },
        npsGetPieChartData:{
            type: new GraphQLList(NpsType),
            args: { day : {type: GraphQLInt}},
            async resolve(parent, args){
                const query = `select x."metricsDetailsSummary_metrics_label_name" as "labelName", round(sum(x."metricsDetailsSummary_metrics_label_count") * 100.0 /
                nullif ((select sum(y."metricsDetailsSummary_metrics_label_count") from public."metrics-details-summary-sink" y where extract(day from y."completedDateTime") = $1 and y."metricsDetailsSummary_metrics_name" = 'nps'),0)) as "labelPercent"
                from public."metrics-details-summary-sink" x where extract (day from x."completedDateTime") = $1 and x."metricsDetailsSummary_metrics_name" = 'nps'
                group by x."metricsDetailsSummary_metrics_label_name"`
                const values = [args.day];
                const res = await db.any(query, values);
                return res;
            }
        },
    }
});

exports.query = RootQuery;