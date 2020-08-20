const graphql = require("graphql");
const { GraphQLObjectType, GraphQLString, GraphQLInt, GraphQLID, GraphQLFloat } = graphql;

const MetricsType = new GraphQLObjectType({
  name: "Metrics",
  type: "Query",
  fields: () => ({
    id: { type: GraphQLID },
    created: { type: GraphQLString},
    version: {type: GraphQLString},
    meshID: {type: GraphQLString},
    sequenceMarker: {type: GraphQLString},
    extractionWindow_fromDateTime: {type: GraphQLString},
    extractionWindow_toDateTime: {type: GraphQLString},
    completedDateTime: {type: GraphQLString},
    MetricsDetails_programId: {type: GraphQLString},
    MetricsDetails_programName: {type: GraphQLString},
    MetricsDetails_programCode: {type: GraphQLString},
    MetricsDetails_listeningPost_label: {type: GraphQLString},
    MetricsDetails_listeningPost_coordinates_latitude: {type: GraphQLFloat},
    MetricsDetails_listeningPost_coordinates_longitude: {type: GraphQLFloat},
    MetricsDetails_listeningPost_coordinates_altitude: {type: GraphQLFloat},
    MetricsDetails_listeningPost_coordinates_altitude: {type: GraphQLString},
    MetricsDetails_listeningPost_class: {type: GraphQLString},
    MetricsDetails_listeningPost_source: {type: GraphQLString},
    MetricsDetails_submissionCount: {type: GraphQLInt},
    MetricsDetails_metrics_name: {type: GraphQLString},
    MetricsDetails_metrics_score: {type: GraphQLFloat},
    MetricsDetails_metrics_label_name: {type: GraphQLString},
    MetricsDetails_metrics_label_count: {type: GraphQLInt},
    MetricsDetails_metrics_nname: {type: GraphQLString},
    avgScore: {type: GraphQLFloat},
    hour: {type: GraphQLInt},
    distinctLabel: {type: GraphQLString},
    distinctName: {type: GraphQLString},
    distinctDay: {type: GraphQLInt},
    labelName: {type: GraphQLString},
    labelPercent: {type: GraphQLFloat}
  })
});

exports.MetricsType = MetricsType;
