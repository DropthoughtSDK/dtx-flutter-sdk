const graphql = require("graphql");
const { GraphQLObjectType, GraphQLString, GraphQLInt, GraphQLFloat } = graphql;

const NpsType = new GraphQLObjectType({
  name: "Nps",
  type: "Query",
  fields: () => ({
    completedDateTime: {type: GraphQLString},
    metricsDetailsSummary_metrics_score: {type: GraphQLFloat},
    metricsDetailsSummary_metrics_name: {type: GraphQLString},
    metricsDetailsSummary_metrics_label_nam : {type: GraphQLString},
    avgScore: {type: GraphQLFloat},
    avgScoreDay: {type: GraphQLInt},
    hour: {type: GraphQLInt},
    distinctName: {type: GraphQLString},
    distinctDay: {type: GraphQLInt},
    labelName: {type: GraphQLString},
    labelPercent: {type: GraphQLFloat},
    distinctLabel: {type: GraphQLString},
    distinctContributorsCount: {type: GraphQLInt}
  })
});

exports.NpsType = NpsType;
