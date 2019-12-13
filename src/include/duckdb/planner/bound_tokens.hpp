//===----------------------------------------------------------------------===//
//                         DuckDB
//
// ../../../src/include/duckdb/planner/bound_tokens.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

namespace duckdb {

//===--------------------------------------------------------------------===//
// Statements
//===--------------------------------------------------------------------===//
class BoundSQLStatement;

class BoundCopyStatement;
class BoundCreateIndexStatement;
class BoundCreateTableStatement;
class BoundDeleteStatement;
class BoundExecuteStatement;
class BoundExplainStatement;
class BoundInsertStatement;
class BoundSelectStatement;
class BoundUpdateStatement;
class BoundSimpleStatement;

//===--------------------------------------------------------------------===//
// Query Node
//===--------------------------------------------------------------------===//
class BoundQueryNode;
class BoundSelectNode;
class BoundSetOperationNode;

//===--------------------------------------------------------------------===//
// Expressions
//===--------------------------------------------------------------------===//
class Expression;

class BoundAggregateExpression;
class BoundCaseExpression;
class BoundCastExpression;
class BoundColumnRefExpression;
class BoundComparisonExpression;
class BoundConjunctionExpression;
class BoundConstantExpression;
class BoundDefaultExpression;
class BoundFunctionExpression;
class BoundOperatorExpression;
class BoundParameterExpression;
class BoundReferenceExpression;
class BoundSubqueryExpression;
class BoundWindowExpression;
class CommonSubExpression;

//===--------------------------------------------------------------------===//
// TableRefs
//===--------------------------------------------------------------------===//
class BoundTableRef;

class BoundBaseTableRef;
class BoundCrossProductRef;
class BoundJoinRef;
class BoundSubqueryRef;
class BoundTableFunction;
class BoundEmptyTableRef;
class BoundExpressionListRef;

} // namespace duckdb
