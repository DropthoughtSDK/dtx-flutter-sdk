"use strict";
const graphql = require("graphql");
const express = require("express");
const expressGraphQl = require("express-graphql");
const { GraphQLSchema } = graphql;
const { query } = require("./schemas/queries");
const cors = require('cors');

const schema = new GraphQLSchema({
  query
});
var app = express();

app.use(cors());

app.use(
  '/',
  expressGraphQl({
    schema: schema,
    graphiql: true
  })
);

app.listen(3000, () =>
  console.log('GraphQL server running on localhost:3000')
);